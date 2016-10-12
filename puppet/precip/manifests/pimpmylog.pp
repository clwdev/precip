class precip::pimpmylog {  
  vcsrepo { "/vagrant/util/pml":
    ensure    => latest,
    provider  => git,
    require   => Package["git"],
    source    => "https://github.com/potsky/PimpMyLog.git",
    revision  => 'master'
  }
}