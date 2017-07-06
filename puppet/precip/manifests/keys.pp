class precip::keys {
  # Turns out in *some* situations, like a heavily locked-down network, you 
  # can't do key exchange the normal way using apt::key. It fails *very* 
  # messily, and then you can't install things via a apt, and that's bad! 
  # Breaking our required external keys into a separate include will make it 
  # easier to conditionally require them during the Box Packing Process.

  # Ondrej's PPA key
  apt::key { 'ppa:ondrej':
    id     => '14AA40EC0831756756D7F66C4F4EA0AAE5267A6C',
    server => 'keyserver.ubuntu.com',
  }
  
  # MariaDB's PPA key
  apt::key { 'mariadb':
    id     => '177F4010FE56CA3336300305F1656F24C74CD1D8',
    server => 'keyserver.ubuntu.com',
  }
}