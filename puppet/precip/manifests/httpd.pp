class precip::httpd {
  # Need to specifically ask for Prefork, otherwise Ubuntu will go grab Worker
  # (Worker is weird)
  class { 'apache': mpm_module => 'prefork' }
  class { 'apache::mod::ssl': }
  class { 'apache::mod::rewrite': }
  class { 'apache::mod::actions': }
  class { 'apache::mod::fastcgi': }

  # Set up some FastCGI Servers
  apache::fastcgi::server { 'php56':
    host       => '/run/php/php5.6-fpm.sock',
    timeout    => 300,
    flush      => false,
    faux_path  => '/var/www/php56.fcgi',
    fcgi_alias => '/php56.fcgi',
    file_type  => 'application/x-httpd-php-5.6'
  }
  
  apache::fastcgi::server { 'php70':
    host       => '/run/php/php7.0-fpm.sock',
    timeout    => 300,
    flush      => false,
    faux_path  => '/var/www/php70.fcgi',
    fcgi_alias => '/php70.fcgi',
    file_type  => 'application/x-httpd-php-7.0'
  }

  apache::fastcgi::server { 'php71':
    host       => '/run/php/php7.1-fpm.sock',
    timeout    => 300,
    flush      => false,
    faux_path  => '/var/www/php71.fcgi',
    fcgi_alias => '/php71.fcgi',
    file_type  => 'application/x-httpd-php-7.1'
  }

  apache::fastcgi::server { 'php72':
    host       => '/run/php/php7.2-fpm.sock',
    timeout    => 300,
    flush      => false,
    faux_path  => '/var/www/php72.fcgi',
    fcgi_alias => '/php72.fcgi',
    file_type  => 'application/x-httpd-php-7.2'
  }

  # We'll also need this if there are any commands defined
  file { '/vagrant/bin':
    ensure => 'directory'
  }

  # a testing vhost
  apache::vhost { 'precip.vm':
    docroot        => '/vagrant/util',
    manage_docroot => false,
    port           => '80',
    directories    => [{
        path           => '/vagrant/util',
        allow_override => ['All',],
    }],
    access_log     => false,
    custom_fragment => 'AddType application/x-httpd-php-7.1 .php'
  }

  apache::vhost { '56.precip.vm':
    docroot        => '/vagrant/util',
    manage_docroot => false,
    port           => '80',
    directories    => [{
        path           => '/vagrant/util',
        allow_override => ['All',],
    }],
    access_log     => false,
    custom_fragment => 'AddType application/x-httpd-php-7.0 .php'
  }

  apache::vhost { '70.precip.vm':
    docroot        => '/vagrant/util',
    manage_docroot => false,
    port           => '80',
    directories    => [{
        path           => '/vagrant/util',
        allow_override => ['All',],
    }],
    access_log     => false,
    custom_fragment => 'AddType application/x-httpd-php-7.0 .php'
  }

  apache::vhost { '71.precip.vm':
    docroot        => '/vagrant/util',
    manage_docroot => false,
    port           => '80',
    directories    => [{
        path           => '/vagrant/util',
        allow_override => ['All',],
    }],
    access_log     => false,
    custom_fragment => 'AddType application/x-httpd-php-7.1 .php'
  }

  apache::vhost { '72.precip.vm':
    docroot        => '/vagrant/util',
    manage_docroot => false,
    port           => '80',
    directories    => [{
        path           => '/vagrant/util',
        allow_override => ['All',],
    }],
    access_log     => false,
    custom_fragment => 'AddType application/x-httpd-php-7.2 .php'
  }

  $parsed_siteinfo = parsejson($drupal_siteinfo)
  create_resources(drupal_vhosts, $parsed_siteinfo)

  # Create Drush aliases
  file { '/vagrant/vm.aliases.drushrc.php':
    content => template('precip/drush_vm_aliases.erb'),
    replace => true,
    mode    => '0644',
  }

  file { '/vagrant/vmi.aliases.drushrc.php':
    content => template('precip/drush_vmi_aliases.erb'),
    replace => true,
    mode    => '0644',
  }
}

define drupal_vhosts($host, $aliases = [], $path, $drupal = '7', $multisite_dir = 'default', $setenv = [], $git_url = '', $git_dir = '', $commands = {}, $ssl_cert = '/vagrant/ssl/precip_vm_host.pem', $ssl_ca = '/vagrant/ssl/precip_ca_bundle.crt.pem', $ssl_key = '/vagrant/ssl/precip_vm_host-key.pem', $php_version = '7.1') {
  apache::vhost { $host:
    docroot        => "/srv/www/${path}",
    manage_docroot => false,
    servername     => $host,
    serveraliases  => $aliases,
    port           => '80',
    directories    => [{
        path           => "/srv/www/${path}",
        allow_override => ['All',],
    }],
    setenv         => concat($setenv,
      [
        "AH_SITE_GROUP ${name}",
        'AH_SITE_ENVIRONMENT vm'
      ]
    ),
    access_log     => false,
    error_log_file => "${host}_error.log",
    custom_fragment => "AddType application/x-httpd-php-${php_version} .php"
  }
  apache::vhost { "${host}-ssl":
    docroot        => "/srv/www/${path}",
    manage_docroot => false,
    servername     => $host,
    serveraliases  => $aliases,
    port           => '443',
    directories    => [{
        path           => "/srv/www/${path}",
        allow_override => ['All',],
    }],
    setenv         => concat($setenv,
      [
        "AH_SITE_GROUP ${name}",
        'AH_SITE_ENVIRONMENT vm'
      ]
    ),
    access_log     => false,
    error_log_file => "${host}_error.log",
    custom_fragment => "AddType application/x-httpd-php-${php_version} .php",
    ssl            => true,
    ssl_cert       => $ssl_cert,
    ssl_ca         => $ssl_ca,
    ssl_key        => $ssl_key
  }

  mysql::db { $name:
    user     => $name,
    password => $name,
    host     => 'localhost',
    grant    => ['all'],
    charset  => 'utf8mb4',
    collate  => 'utf8mb4_unicode_ci',
  }

  mysql_user { "${name}@%":
    ensure        => 'present',
    password_hash => mysql_password($name),
    subscribe     =>  Service['mysqld']
  }

  mysql_grant { "${name}@%/${name}.*":
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => "${name}.*",
    user       => "${name}@%",
    require    => [ Mysql_database[$name], Mysql_user["${name}@%"] ],
  }

  if $drupal != 'false' {
    file {"/srv/www/${path}/sites/${multisite_dir}":
      ensure =>'directory',
      mode   => '0775',
    }

    # "local-settings.inc", a way of setting extra stuff for local development
    file {"/srv/www/${path}/sites/${multisite_dir}/local-settings.inc":
      content   => template("precip/drupal_${drupal}_local_settings_inc.erb"),
      replace   => false,
      mode      => '0775',
      subscribe => File["/srv/www/${path}/sites/${multisite_dir}"],
    }

    # An Acquia-style settings.php, if you need one.
    file { "/srv/www/${path}/sites/${multisite_dir}/settings.php":
      content   => template("precip/drupal_${drupal}_settings_php.erb"),
      replace   => false,
      mode      => '0775',
      subscribe => File["/srv/www/${path}/sites/${multisite_dir}"],
    }
  }

  # Let's make some shell commands!
  if empty($commands) != true {
    create_resources(command_builder, $commands)
  }
}

define command_builder($path, $cmd){
  file { "/vagrant/bin/${name}":
    content => template('precip/shell_command.erb'),
    replace => true,
    mode    => '0755',
    require => File['/vagrant/bin'],
  }
}
