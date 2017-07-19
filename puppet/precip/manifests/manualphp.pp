class precip::manualphp {
  # All Puppet PHP Modules are Terrible.
  # Let's not use them.
  
  # Get Ondrej's PPA
  ::apt::ppa { "ppa:ondrej/php": }
  
  # Get all the PHP 7 deps
  package{[
    'php7.0-cli',
    'php7.0-common',
    'php7.0-curl',
    'php7.0-dev',
    'php7.0-fpm',
    'php7.0-gd',
    'php7.0-intl',
    'php7.0-json',
    'php7.0-mbstring',
    'php7.0-mcrypt',
    'php7.0-mysql',
    'php7.0-opcache',
    'php7.0-readline',
    'php7.0-sqlite3',
    'php7.0-xml',
    'php7.0-zip',
    ]:
    ensure  => present,
    require => [Apt::Ppa['ppa:ondrej/php'], Class['apt::update']],
  }

  # Get all the PHP 5.6 deps
  package{[
    'php5.6-cli',
    'php5.6-common',
    'php5.6-curl',
    'php5.6-dev',
    'php5.6-fpm',
    'php5.6-gd',
    'php5.6-intl',
    'php5.6-json',
    'php5.6-mbstring',
    'php5.6-mcrypt',
    'php5.6-mysql',
    'php5.6-opcache',
    'php5.6-readline',
    'php5.6-sqlite3',
    'php5.6-xml',
    'php5.6-zip',
    ]:
    ensure  => present,
    require => [Apt::Ppa['ppa:ondrej/php'], Class['apt::update']],
  }
  
  # . . and the ones we only need once
  package{[
    'php-igbinary',
    'php-imagick',
    'php-memcached',
    'php-msgpack',
    'php-pear',
    'php-xdebug',
    ]:
    ensure  => present,
    require => [Apt::Ppa['ppa:ondrej/php'], Class['apt::update']],
  }
  
  # config files
  file { '/etc/php/5.6/mods-available/xdebug.ini':
    ensure  => 'file',
    content => template('precip/php56_xdebug.erb'),
    mode    => '0644',
    require => Package['php-xdebug'],
  }

  file { '/etc/php/7.0/mods-available/xdebug.ini':
    ensure  => 'file',
    content => template('precip/php70_xdebug.erb'),
    mode    => '0644',
    require => Package['php-xdebug'],
  }
  
  exec { 'sudo phpenmod -v ALL -s ALL xdebug && service php5.6-fpm reload && service php7.0-fpm reload':
    path    => '/usr/sbin:/usr/bin:/bin',
    #onlyif  => ['test `php5.6 --version|grep Xdebug -c` -eq 0','test `php7.0 --version|grep Xdebug -c` -eq 0'],
    require => File['/etc/php/5.6/mods-available/xdebug.ini','/etc/php/7.0/mods-available/xdebug.ini']
  }
}