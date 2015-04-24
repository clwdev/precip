class acdrupal {
  
  # ~magic incantations~ to ensure apt-get update runs before any package is installed
  Exec["apt_update"] -> Package <| |>
  
  class { 'apt': }
  
  # Grab some helpful base packages
  package {[
    "ntp",
    "htop",
    "curl",
    "wget",
    "bzip2",
    "git",
    "openssl",
    "imagemagick",
    "vim",
    "g++",
    ]:
    ensure => present,
  }

  # Make our log directory
  file {"/vagrant/log": ensure => "directory", }

  # Fix the timezone with a symlink
  file { '/etc/localtime':
    ensure => "link",
    force => "true",
    target => "/usr/share/zoneinfo/US/Eastern",
  }

  # Bring in Mailcatcher, because Mailcatcher is neat.
  class { 'mailcatcher': 
    require => Package['g++']
  }

  # Kick off the rest of our manifests
  include 'acdrupal::php'
  include 'acdrupal::httpd'
  include 'acdrupal::database'
  
}
