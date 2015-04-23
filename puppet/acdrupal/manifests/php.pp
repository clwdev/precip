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
}
