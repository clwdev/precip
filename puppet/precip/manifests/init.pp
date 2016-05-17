class precip {
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

  # Install a variety of Language Packs
  package {[
    "language-pack-de",
    "language-pack-en",
    "language-pack-es",
    "language-pack-fr",
    "language-pack-it",
    # "language-pack-ja",
    "language-pack-nl",
    "language-pack-nn",
    "language-pack-pt",
    "language-pack-ru",
    "language-pack-sv",
    "language-pack-zh-hans",
    "language-pack-zh-hant",
    ]:
    ensure => present,
  }

  # Grab some gems.
  # @TODO: Convert to a bundle? Define a bundle path in config.rb and bundle install each of those?
  package {[
    "compass",
    "breakpoint",
    "sass",
    "susy",
    ]:
    ensure => 'installed',
    provider => 'gem',
  }

  # Make our log directory
  file {"/vagrant/log": ensure => "directory", }

  # Fix the timezone with a symlink
  file { '/etc/localtime':
    ensure => "link",
    force => "true",
    target => "/usr/share/zoneinfo/US/Eastern",
  }

  if str2bool("$first_boot") {
    # Install statically-compiled versions of wkhtmltopdf / wkhtmltoimage
    class { 'wkhtmltox':
      ensure => present,
    }

    # Install MailHog & ssmtp, an alternative to Mailcatcher
    class { '::ssmtp':
      mail_hub => 'localhost:1025',
    }

    class { 'mailhog':
      api_bind_host => 'precip.vm',
    }
  }

  # Add all our hosts to /etc/hosts
  host { 'local.vm':
    ip => '127.0.0.1',
    host_aliases => parsejson($drupal_hosts),
  }

  # Kick off the rest of our manifests
  include 'precip::php'
  include 'precip::httpd'
  include 'precip::database'
  
  # More elegant workaround for vbguest's issue #95
  # See: https://github.com/dotless-de/vagrant-vbguest/issues/95#issuecomment-163777475
  file { '/sbin/vboxadd':
    ensure => "link",
    force => "true",
    target => "/sbin/rcvboxadd",
  }
  
  file { "/etc/init/restart_services_once_mounted.conf":
    content => template("precip/restart_services_once_mounted.conf.erb"),
    ensure  => 'file',
    mode    => '0644',
  }
}
