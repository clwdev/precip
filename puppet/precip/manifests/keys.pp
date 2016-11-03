class precip::keys {
  # Turns out in *some* situations, like a heavily locked-down network, you 
  # can't do key exchange the normal way using apt::key. It fails *very* 
  # messily, and then you can't install things via a apt, and that's bad! 
  # Breaking our required external keys into a separate include will make it 
  # easier to conditionally require them during the Box Packing Process.

  # Percona's keys
  apt::key { 'percona':
    id     => '430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A',
    server => 'keyserver.ubuntu.com',
  }
  
  apt::key { 'percona-packaging':
    id     => '4D1BB29D63D98E422B2113B19334A25F8507EFA5',
    server => 'keyserver.ubuntu.com',
  }
  
  # Ondrej's PPA key
  apt::key { 'ppa:ondrej':
    id     => '14AA40EC0831756756D7F66C4F4EA0AAE5267A6C',
    server => 'keyserver.ubuntu.com',
  }
}