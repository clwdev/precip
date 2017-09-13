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

  # MariaDB's Package Signing key
  apt::key { 'mariadb':
    id     => '177F4010FE56CA3336300305F1656F24C74CD1D8',
    server => 'keyserver.ubuntu.com',
  }
  
  # Yarn's Package Signing Key

  # Yarn helpfully added a new subkey to their repo with the release of 1.0.0, 
  # but haven't published it to the Ubuntu Keyserver. So we get to source it
  # directly for the time being. :(

  apt::key { 'yarn':
    id     => '72ECF46A56B4AD39C907BBB71646B01B86E50310',
    #server => 'keyserver.ubuntu.com',
    source => 'https://dl.yarnpkg.com/debian/pubkey.gpg',
  }
}