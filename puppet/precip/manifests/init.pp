class precip {
  class { 'apt': }

  # Grab some helpful base packages
  package {[
    'ntp',
    'htop',
    'curl',
    'wget',
    'unzip',
    'bzip2',
    'git',
    'openssl',
    'imagemagick',
    'vim',
    'g++',
    'software-properties-common',
    ]:
    ensure => present,
  }

  # Install a variety of Language Packs
  package {[
    'language-pack-de',
    'language-pack-en',
    'language-pack-es',
    'language-pack-fr',
    'language-pack-it',
    # 'language-pack-ja',
    'language-pack-nl',
    'language-pack-nn',
    'language-pack-pt',
    'language-pack-ru',
    'language-pack-sv',
    'language-pack-zh-hans',
    'language-pack-zh-hant',
    ]:
    ensure => present,
  }

  # Tools needed to build Omega-based themes
  package {[
    'bundler',
    'compass',
    'breakpoint',
    'sass',
    'susy',
    ]:
    ensure => 'installed',
    provider => 'gem',
  }

  # Define the Yarn apt repo
  apt::source { 'yarn':
    location => 'http://dl.yarnpkg.com/debian/',
    release  => 'stable',
    repos    => 'main',
    require  => [
      Apt::Key['yarn']
    ]
  }

  # Tools needed to build Radix-based themes
  package {[
    'nodejs',
    'npm',
    'yarn',
    ]:
    require => [Apt::Source['yarn'],Class['apt::update']],
    ensure  => present,
  }

  # Make our log directory
  file {'/vagrant/log': ensure => 'directory', }

  # Fix the timezone with a symlink
  file { '/etc/localtime':
    ensure => 'link',
    force  => true,
    target => '/usr/share/zoneinfo/US/Eastern',
  }

  # Awful hack to fix the permissions on ssmtp's config file
  define check_mode($mode) {
    exec { "/bin/chmod $mode $name":
      unless => "/bin/sh -c '[ $(/usr/bin/stat -c %a $name) == $mode ]'",
    }
  }

  # Add all our hosts to /etc/hosts
  host { 'local.vm':
    ip           => '127.0.0.1',
    host_aliases => parsejson($drupal_hosts),
  }

  $parsed_hosts = parsejson($external_hosts)
  create_resources(host, $parsed_hosts)

  # Install Memcached
  class { 'memcached': }

  # Install Mailhog, back to being handled by ftaeger-mailhog
  class { 'mailhog': }

  # Kick off the rest of our manifests
  include 'precip::keys'
  if !str2bool("$packaging_mode") {
    include 'precip::php'
    include 'precip::httpd'
    include 'precip::database'
    include 'precip::pimpmylog'
  }

  # Ensure vagrant owns /usr/local/bin
  file { '/usr/local/bin':
    ensure => 'directory',
    owner  => 'vagrant',
    group  => 'vagrant',
  }

  # More elegant workaround for vbguest's issue #95
  # See: https://github.com/dotless-de/vagrant-vbguest/issues/95#issuecomment-163777475
  file { '/sbin/vboxadd':
    ensure => 'link',
    force  => true,
    target => '/sbin/rcvboxadd',
  }

  file { '/etc/init/restart_services_once_mounted.conf':
    ensure  => 'file',
    content => template('precip/restart_services_once_mounted.conf.erb'),
    mode    => '0644',
  }
}