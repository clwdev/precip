class acdrupal::php {
  
  class { 'php::cli': }
  
  file {[
      '/etc/php5/',
      '/etc/php5/cli',
      '/etc/php5/apache2',
      '/etc/php5/conf.d'
    ]:
    ensure => "directory",
  }
  
  php::ini {[
      '/etc/php.ini',
      '/etc/php5/cli/php.ini',
      '/etc/php5/apache2/php.ini',
    ]:
    max_execution_time => 600,
    max_input_time => 300,
    post_max_size => '50M',
    upload_max_filesize => '50M',
    memory_limit => '256M',
    date_timezone => 'America/New_York',
    max_input_vars => 5000,
    display_errors => 'On',
    html_errors => 'On',
    sendmail_path => '/usr/bin/env catchmail',
    notify => Service['httpd'],
    require => File['/etc/php5/apache2']
  }
  
  php::module {[
    'mysql',
    'intl',
    'mcrypt',
    'gd',
    'curl',
    'xdebug',
    'imagick',
    'xhprof',
    'memcached']:
    notify => Service['httpd'],
  }
  
  php::module::ini { 'xdebug' :
    settings => {
      'xdebug.remote_enable' => '1',
      'xdebug.remote_connect_back' => '1',
      'xdebug.idekey' => 'vagrant',
    },
    zend => '/usr/lib/php5/20121212',
    notify => Service['httpd'],
  }
  
  file { "/etc/php5/mods-available/xdebug.ini":
    ensure  => 'link',
    require => Package['php5-common'],
    target => '/etc/php5/conf.d/xdebug.ini',
    notify => Service['httpd'],
  }

  $opcache_settings = {
    'opcache.revalidate_freq' => '0',
    'opcache.memory_consumption' => '512',
    'opcache.max_accelerated_files' => '10000',
    'opcache.interned_strings_buffer' => '16',
    'opcache.fast_shutdown' => '1',
  }

  file { "/etc/php5/mods-available/opcache.ini":
    ensure  => 'file',
    require => Package['php5-common'],
    content => template('acdrupal/opcache.ini.erb'),
    notify => Service['httpd'],
  }
  
  # We don't *actually* need Composer right now, so I'm blocking 
  # this section out until we actually need it for something.
  #
  # class { 'composer': 
  #   require => Class['php::cli']
  # }
  # 
  # file { "/home/vagrant/.composer/":
  #   ensure => 'directory',
  #   mode => '0755',
  #   owner => "vagrant",
  #   group => "vagrant",
  #   require => Class['composer'],
  # }
  # 
  # file { "/home/vagrant/.composer/composer.json":
  #   content => template("acdrupal/composer.json"),
  #   ensure  => 'file',
  #   mode    => '0644',
  #   owner => "vagrant",
  #   group => "vagrant",
  #   require => [Class['composer'], File['/home/vagrant/.composer/']],
  # }
  #   
  # exec { "composer-install":
  #   command => "composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader",
  #   environment => [ "HOME=/home/vagrant", "COMPOSER_HOME=/home/vagrant/.composer" ],
  #   cwd => "/home/vagrant/.composer",
  #   path => "/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin",
  #   user => "vagrant",
  #   require => [Class['composer'], File["/home/vagrant/.composer/composer.json"]],
  # }
  # 
  # # Ensures that Drush will be available from outside the box
  # file { '/home/vagrant/.pam_environment':
  #   mode    => 644,
  #   content => 'PATH DEFAULT=${PATH}:/home/vagrant/.composer/vendor/bin',
  #   require => Class['composer'],
  # }
}
