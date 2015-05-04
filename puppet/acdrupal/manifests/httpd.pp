class acdrupal::httpd {
  # Need to specifically ask for Prefork, otherwise Ubuntu will go grab Worker
  # (Worker is weird)
  class { 'apache': mpm_module => "prefork" }
  class { 'apache::mod::php': }
  class { 'apache::mod::ssl': }

  # We'll need this when we make our vhosts
  file {"/var/www/site-php":
    ensure => "directory",
    mode => '0755',
  }

  # a testing vhost
  apache::vhost { "drupal.vm":
    docroot => "/vagrant/util",
    manage_docroot => false,
    port => '80',
    directories => [{
        path => "/vagrant/util",
        allow_override => ['All',],
    }],
    access_log => false,
        logroot => "/vagrant/log",
  }

  $parsed_siteinfo = parsejson($drupal_siteinfo)
  create_resources(drupal_vhosts, $parsed_siteinfo)
  
  # Create Drush aliases
  file { "/vagrant/vm.aliases.drushrc.php":
    content => template("acdrupal/drush_aliases.erb"),
    replace => true,
    mode => '0644',
  }
}

define drupal_vhosts($host, $aliases = [], $path, $drupal = "7", $multisite_dir = "default") {
    apache::vhost { "${host}":
    docroot => "/srv/www/${path}",
    manage_docroot => false,
    servername => "${host}",
    serveraliases => $aliases,
    port => '80',
    directories => [{
        path => "/srv/www/${path}",
        allow_override => ['All',],
    }],
    setenv => [
        "AH_SITE_GROUP ${name}",
        "AH_SITE_ENVIRONMENT vm"
    ],
    access_log => false,
    logroot => "/vagrant/log",
    require => File["/vagrant/log"],
  }
  apache::vhost { "${host}-ssl":
    docroot => "/srv/www/${path}",
    manage_docroot => false,
    servername => "${host}",
    serveraliases => $aliases,
    port => '443',
    directories => [{
        path => "/srv/www/${path}",
        allow_override => ['All',],
    }],
    setenv => [
        "AH_SITE_GROUP ${name}",
        "AH_SITE_ENVIRONMENT vm"
    ],
    access_log => false,
    logroot => "/vagrant/log",
    ssl => true,
    require => File["/vagrant/log"],
  }
  
  mysql::db { $name:
    user     => "${name}",
    password => "${name}",
    host     => 'localhost',
    grant    => ['all'],
  }
  
  mysql_user { "${name}@%":
    ensure        => 'present',
    password_hash => mysql_password("${name}"),
    subscribe    =>  Service['mysqld']
  }
  
  mysql_grant { "${name}@%/${name}.*":
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => "${name}.*",
    user       => "${name}@%",
    require    => [ Mysql_database["$name"], Mysql_user["$name@%"] ],
  }
  
  if $drupal != "false" {
    file {"/srv/www/${path}/sites/${multisite_dir}":
      ensure =>'directory',
      mode => '0755',
    }

    # Ensure the tree we're going to hide settings in exists
    file {"/var/www/site-php/${name}":
      ensure => "directory",
      mode => '0755',
      require => File["/var/www/site-php"],    
    }

    # Magic Acquia-style Database Settings.
    file { "/var/www/site-php/${name}/${name}-settings.inc":
      content => template("acdrupal/drupal_${drupal}_database.erb"),
      replace => false,
      mode => '0644',
      subscribe => File["/var/www/site-php/${name}"],
    }
    
    # An Acquia-style settings.php, if you need one.
    file { "/srv/www/${path}/sites/${multisite_dir}/settings.php":
      content => template("acdrupal/drupal_${drupal}_settings_php.erb"),
      replace => false,
      mode => '0644',
      subscribe => File["/srv/www/${path}/sites/${multisite_dir}"],
    }
  }
}
