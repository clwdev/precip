# Adapted from Chassis/MailHog
class precip::mailhog ( 
  $install_path = '/usr/local/bin/mailhog', 
  $mailhog_version = '0.2.1',
  $mhsendmail_version = '0.2.0',
  ) {

	file { $install_path:
		ensure => directory,
	}

  # Download & Link Mailhog
	exec { "mailhog download $mailhog_version":
		command => "/usr/bin/curl -o $install_path/mailhog-$mailhog_version -L https://github.com/mailhog/MailHog/releases/download/v$mailhog_version/MailHog_linux_amd64",
		require => [ Package['curl'], File[ "$install_path" ] ],
		creates => "$install_path/mailhog-$mailhog_version",
	}

	file { "$install_path/mailhog-$mailhog_version":
		ensure => present,
		mode => "a+x",
		require => Exec["mailhog download $mailhog_version"],
    notify => File['/usr/bin/mailhog'],
	}

	file { '/usr/bin/mailhog':
		ensure => link,
		target => "$install_path/mailhog-$mailhog_version",
		require => File[ "$install_path/mailhog-$mailhog_version" ],
	}

  # Download & Link mhsendmail
  exec { "mhsendmail download $mhsendmail_version":
		command => "/usr/bin/curl -o $install_path/mhsendmail-$mhsendmail_version -L https://github.com/mailhog/mhsendmail/releases/download/v$mhsendmail_version/mhsendmail_linux_amd64",
		require => [ Package['curl'], File[ "$install_path" ] ],
		creates => "$install_path/mhsendmail-$mhsendmail_version",
	}

  file { "$install_path/mhsendmail-$mhsendmail_version":
		ensure => present,
		mode => "a+x",
		require => Exec["mhsendmail download $mhsendmail_version"],
    notify => File['/usr/bin/mhsendmail'],
	}

	file { '/usr/bin/mhsendmail':
		ensure => link,
		target => "$install_path/mhsendmail-$mhsendmail_version",
		require => File[ "$install_path/mhsendmail-$mhsendmail_version" ],
	}

	file { '/etc/init/mailhog.conf':
		content => template('precip/mailhog_upstart.conf.erb'),
	}

	service { 'mailhog':
    enable => true,
    ensure => running,
    hasrestart => true,
    hasstatus => true,
    require => [ File['/etc/init/mailhog.conf'], File['/usr/bin/mailhog'] ]
	}

	if ! defined(Package['curl']) {
		package { 'curl':
			ensure => installed,
		}
	}
}