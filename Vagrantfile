# Ensure we've got some Helpful Plugins
%x(vagrant plugin install vagrant-vbguest) unless Vagrant.has_plugin?('vagrant-vbguest')
%x(vagrant plugin install vagrant-hostsupdater) unless Vagrant.has_plugin?('vagrant-hostsupdater')
%x(vagrant plugin install vagrant-useradd) unless Vagrant.has_plugin?('vagrant-useradd')
%x(vagrant plugin install vagrant-bindfs) unless Vagrant.has_plugin?('vagrant-bindfs')
%x(vagrant plugin install vagrant-persistent-storage) unless Vagrant.has_plugin?('vagrant-persistent-storage')

# Pull in external config
require "json"
drupal_sites = ""
drupal_basepath = "sites"
external_hosts = {}

# Determine if this is our first boot or not. 
# If there's a better way to figure this out we now have a single place to change.
first_boot = true
if File.file?('.vagrant/machines/default/virtualbox/action_provision')
  first_boot = false
end

ext_config = File.read 'config.rb'
eval ext_config

# Clone repos if necessary
drupal_sites.each do |name, site|
  if site.has_key?("git_url") && site.has_key?("git_dir") && !Dir.exists?( Dir.pwd + "/" + drupal_basepath + "/" + site['git_dir'] + "/.git")
    puts "No Git Clone found for \"#{name}\""
    git_cmd = "git clone #{site['git_url']} #{drupal_basepath}/#{site['git_dir']}"
    %x{ #{git_cmd} }
  end
end

# The actual Vagrant Configuration
Vagrant.configure(2) do |config|
  # Vagrant Box Address
  # This is a happy base box from PuppetLabs
  config.vm.box = "puppetlabs/ubuntu-14.04-64-puppet"
  # Pin to 1.0.0 for perf reasons
  config.vm.box_version = "1.0.0"

  # Basic network config.
  config.vm.network :private_network, ip: "10.0.0.11"
  config.vm.hostname = "precip.vm"
  config.hostsupdater.aliases = drupal_sites.collect { |k,v| v["host"] }.concat(drupal_sites.collect { |k,v| v["aliases"] }.flatten.select! { |x| !x.nil? })

  # Ensure users exist before we mount stuff
  config.useradd.users = {
    'www-data' => ['www-data'],
    'mysql' => nil,
    'vagrant' => ['vagrant','www-data'],
  }

  # Disabling vbguest is helpful in development
  # config.vbguest.auto_update = false

  # Synced Folders
  if Vagrant::Util::Platform.windows?
    # Windows gets vboxsf, because it can't do nfs + bindfs
    config.vm.synced_folder drupal_basepath, "/srv/www", owner: "www-data", group: "www-data"
  else
    # Everybody else gets nfs + bindfs, for better small-file read perf
    config.vm.synced_folder drupal_basepath, "/nfs-www", type: "nfs"
    config.bindfs.bind_folder "/nfs-www", "/srv/www", user: "vagrant", group: "www-data", chown_ignore: true, chgrp_ignore: true, perms: "u=rwx:g=rwx:o=rx"
  end

  # MySQL now uses the vagrant-persistent-storage module.
  # Same concept as before & same benefits, but with the added bonus of being a native filesystem instead of a share.
  config.persistent_storage.enabled = true
  config.persistent_storage.location = "mysql.vdi"
  config.persistent_storage.size = 32768
  config.persistent_storage.mountname = 'mysql'
  config.persistent_storage.filesystem = 'ext4'
  config.persistent_storage.mountpoint = '/var/lib/mysql'
  
  # Want to mount your *old* MySQL dir so you can copy your old files over? 
  # Uncomment this and run: vagrant reload && vagrant ssh -c "sudo bash /vagrant/shell/migrate-db.sh"
  #config.vm.synced_folder "mysql", "/var/lib/mysql-old", owner: "mysql", group: "mysql"
  
  # Mount the gitignored puppet/modules directory, for caching
  config.vm.synced_folder "puppet/modules", "/etc/puppet/modules"

  # Configure the VM. Tweak as needed
  configured = -1
  config.vm.provider :virtualbox do |vb|
    # Name this virtual machine "precip"
    vb.customize ["modifyvm", :id, "--name", "precip"]
    # IOAPIC is needed for a 64bit host for multiple cures
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    # Use ICH9 for performance
    vb.customize ["modifyvm", :id, "--chipset", "ich9"]
    # Deffer DNS resolution to the host for performance
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    # Prevent Virtualbox status errors about vram
    vb.customize ["modifyvm", :id, "--vram", "10"]
    # Prevent a time drift of more than a minute from the host
    vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 60000]
    # Give VM 1/4 system memory (if more than 2GB), otherwise leave as default
    # Give half of cpu cores as the host (if more than 1), otherwise leave as default
    # In our testing this produced the best results. Adapted from https://github.com/rdsubhas/vagrant-faster
    host = RbConfig::CONFIG['host_os']
    cpus = -1
    mem = -1
    if host =~ /darwin/
      cpus = `sysctl -n hw.ncpu`.to_i
      mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024
    elsif host =~ /linux/
      cpus = `nproc`.to_i
      mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024
    elsif host =~ /mswin|mingw|cygwin/
      cpus = `wmic cpu Get NumberOfCores`.split[1].to_i
      mem = `wmic computersystem Get TotalPhysicalMemory`.split[1].to_i / 1024 / 1024
    end
    cpus = cpus / 2 if cpus > 1
    mem = mem / 4 if mem > 2048
    if mem > 0
      vb.customize ["modifyvm", :id, "--memory", mem]
      if configured < 1
        puts "Memory set to: #{mem}"
      end
    end
    if cpus > 0
      vb.customize ["modifyvm", :id, "--cpus", cpus]
      if configured < 1
        puts "CPUs set to: #{cpus}"
      end
    end
    configured = 1
  end

  # Fix the harmless "stdin: is not a tty" issue once and for all
  config.vm.provision "fix-no-tty", type: "shell" do |s|
      s.privileged = false
      s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  # Set up and use puppet-librarian inside the box to get all our Puppet Modules
  config.vm.provision "shell", path: "shell/librarian.sh"
  
  # Hand off to puppet
  config.vm.provision :puppet, :options => [""] do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file  = "site.pp"
    puppet.hiera_config_path = "puppet/hiera.yaml"
  
    # some facts
    puppet.facter = {
      "drupal_sites_path" => Dir.pwd + "/" + drupal_basepath,
      "drupal_siteinfo" => drupal_sites.to_json,
      "drupal_hosts" => drupal_sites.collect { |k,v| v["host"] }.concat(drupal_sites.collect { |k,v| v["aliases"] }.flatten.select! { |x| !x.nil? }).to_json,
      "external_hosts" => external_hosts.to_json,
      "first_boot" => first_boot,
    }
  end
end
