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
}