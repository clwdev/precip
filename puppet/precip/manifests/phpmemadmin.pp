class precip::phpmemadmin {
  # Experimental support for phpmemadmin
  
  file { '/vagrant/util/phpmemadmin':
    ensure  => 'directory',
    mode    => '0755',
    owner   => 'vagrant',
    group   => 'vagrant',
    require => Package['composer'],
  }

  file { '/vagrant/util/phpmemadmin/composer.json':
    ensure  => 'file',
    content => template('precip/phpmemadmin-composer.json'),
    mode    => '0644',
    owner   => 'vagrant',
    group   => 'vagrant',
    require => [Package['composer'], File['/vagrant/util/phpmemadmin']],
  }
  
  exec { 'install-composer-phpmemadmin':
    command     => "/bin/echo $'1\n\n' | composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader",
    environment => [ 'HOME=/home/vagrant', 'COMPOSER_HOME=/home/vagrant/.composer' ],
    cwd         => '/vagrant/util/phpmemadmin',
    path        => '/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin',
    user        => 'vagrant',
    require     => [Package['composer'], File['/vagrant/util/phpmemadmin/composer.json']],
  }
}