class precip::pimpmylog {  
  vcsrepo { "/vagrant/util/pml":
    ensure    => latest,
    provider  => git,
    require   => Package["git"],
    source    => "https://github.com/potsky/PimpMyLog.git",
    revision  => 'master'
  }

  $parsed_siteinfo = parsejson($drupal_siteinfo)

  file { "/vagrant/util/pml/config.user.php":
    content   => template('precip/pml_config_user_php.erb'),
    require   => Vcsrepo['/vagrant/util/pml']
  }
}