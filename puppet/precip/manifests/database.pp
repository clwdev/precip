class precip::database {

  # Define the MariaDB apt repo
  apt::source { 'MariaDB':
    location => 'http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.1/ubuntu',
    repos    => 'main',
    require  => [
      Apt::Key['mariadb']
    ]
  }

  class { 'mysql::client':
    package_name   => 'mariadb-client',
    package_ensure => 'latest',
    require        => [
      Apt::Source['MariaDB']
    ]
  }

  class { 'mysql::server':
    package_name     => 'mariadb-server',
    package_ensure   => 'latest',
    override_options => {
      'mysqld'      => {
        'bind-address' => '0.0.0.0',
        'log_error'    => '/vagrant/log/mysql_error.log'
      },
      'mysqld_safe' => {
        'log_error' => '/vagrant/log/mysql_error.log'
      }
    },
    require          => [
      Apt::Source['MariaDB']
    ]
  }

  mysql_user { 'precip@%':
    ensure        => 'present',
    password_hash => mysql_password('precip'),
    subscribe     =>  Service['mysqld']
  }

  mysql_grant { 'precip@%/*.*':
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => '*.*',
    user       => 'precip@%',
    require    => Mysql_user['precip@%'],
  }

  # MySQL isn't *really* available to all hosts until you restart it. 
  # So we need to restart it on *first boot only*.
  if str2bool($first_boot) {
    exec { 'restart-mysqld-after-grant':
      path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin/'],
      command => 'service mysql restart',
      require => Mysql_grant['precip@%/*.*'],
    }
  }
}