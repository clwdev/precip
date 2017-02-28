class precip::php {
  class { '::php':
    manage_repos => true,
    fpm          => false,
    dev          => true,
    composer     => true,
    pear         => false,
    phpunit      => false,
    extensions   => {
      curl       => { },
      gd         => { },
      imagick    => { },
      intl       => { },
      mbstring   => { },
      mcrypt     => { },
      memcached  => { },
      mysql      => { },
      sqlite     => { }, 
      opcache    => {
        settings => {
          'opcache/opcache.enable_cli' => '1',
          'opcache/opcache.revalidate_freq' => '1',
          'opcache/opcache.memory_consumption' => '512',
          'opcache/opcache.max_accelerated_files' => '10000',
          'opcache/opcache.interned_strings_buffer' => '16',
          'opcache/opcache.fast_shutdown' => '1',
        },
      },
      xdebug     => {
        settings => {
          'xdebug/xdebug.remote_autostart' => '1',
          'xdebug/xdebug.remote_enable' => '1',
          'xdebug/xdebug.remote_connect_back' => '1',
          'xdebug/xdebug.idekey' => 'vagrant',
          'xdebug/xdebug.max_nesting_level' => '10000',
        },
      },
    },
    settings     => {
      'PHP/max_execution_time'  => '600',
      'PHP/max_input_time'      => '300',
      'PHP/post_max_size'       => '50M',
      'PHP/upload_max_filesize' => '50M',
      'PHP/memory_limit'        => '256M',
      'PHP/max_input_vars'      => '10000',
      'PHP/realpath_cache_size' => '1024',
      'PHP/display_errors'      => 'On',
      'PHP/html_errors'         => 'On',
      'PHP/session_save_path'   => '/tmp',
      'PHP/sendmail_path'       => '/usr/bin/mailhog sendmail noreply@precip.vm',
      'Date/date.timezone'      => 'America/New_York',
    },
    require => Package["software-properties-common"],
  }

  # Add Composer's vendor directory to the vagrant user's $PATH
  file { '/home/vagrant/.pam_environment':
    mode    => '0644',
    content => 'PATH DEFAULT=${PATH}:/home/vagrant/.composer/vendor/bin',
    require => Class['php'],
  }
  
  # These bits install Drush & Friends via composer
  file { "/home/vagrant/.composer/":
    ensure => 'directory',
    mode => '0755',
    owner => "vagrant",
    group => "vagrant",
    require => Class['php'],
  }
  
  file { "/home/vagrant/.composer/composer.json":
    content => template("precip/composer.json"),
    ensure  => 'file',
    mode    => '0644',
    owner => "vagrant",
    group => "vagrant",
    require => [Class['php'], File['/home/vagrant/.composer/']],
  }
    
  exec { "install-composer-libraries":
    command => "composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader",
    environment => [ "HOME=/home/vagrant", "COMPOSER_HOME=/home/vagrant/.composer" ],
    cwd => "/home/vagrant/.composer",
    path => "/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin",
    user => "vagrant",
    require => [Class['php'], File["/home/vagrant/.composer/composer.json"]],
  }
}
