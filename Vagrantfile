# Ensure we've got some Helpful Plugins
%x(vagrant plugin install vagrant-vbguest) unless Vagrant.has_plugin?('vagrant-vbguest')
%x(vagrant plugin install vagrant-hostsupdater) unless Vagrant.has_plugin?('vagrant-hostsupdater')
%x(vagrant plugin install vagrant-useradd) unless Vagrant.has_plugin?('vagrant-useradd')
%x(vagrant plugin install vagrant-bindfs) unless Vagrant.has_plugin?('vagrant-bindfs')

# Pull in external config
require "json"
drupal_sites = ""
drupal_basepath = ""

ext_config = File.read 'config.rb'
eval ext_config

# The actual Vagrant Configuration
Vagrant.configure(2) do |config|
  # Vagrant Box Address
  # This is a happy base box from PuppetLabs
  config.vm.box = "puppetlabs/ubuntu-14.04-64-puppet"

  # Basic network config.
  config.vm.network :private_network, ip: "10.0.0.11"
  config.vm.hostname = "drupal.vm"
  config.hostsupdater.aliases = drupal_sites.collect { |k,v| v["host"] }

  # Ensure users exist before we mount stuff
  config.useradd.users = {
    'www-data' => ['www-data'],
    'mysql' => nil
  }

  # Disabling vbguest is helpful in development
  config.vbguest.auto_update = false

  # Synced Folders
  # if Vagrant::Util::Platform.windows?
  #   # Windows gets vboxsf for everything. Sorry Windows!
  #   config.vm.synced_folder drupal_basepath, "/srv/www", owner: "www-data", group: "www-data"
  #   config.vm.synced_folder "mysql", "/var/lib/mysql", owner: "mysql", group: "mysql"
  # else
  #   # Everybody else gets nfs + bindfs for their Apache folders
  #   config.vm.synced_folder drupal_basepath, "/nfs-www", type: "nfs"
  #   config.bindfs.bind_folder "/nfs-www", "/srv/www", user: "www-data", group: "www-data"
  #   
  #   # Determine if we've provisioned yet...
  #   if !File.file?('.vagrant/machines/default/virtualbox/action_provision')
  #     # MySQL has to be mounted with vboxsf initially, because MySQL Is Terrible
  #     config.vm.synced_folder "mysql", "/var/lib/mysql", owner: "mysql", group: "mysql"
  #   else 
  #     # Once MySQL is installed during initial provisioning we can re-mount with nfs + bindfs
  #     config.vm.synced_folder "mysql", "/nfs-sql", type: "nfs"
  #     config.bindfs.bind_folder "/nfs-sql", "/var/lib/mysql", user: "mysql", group: "mysql"
  #   end
  # end

  # Throw more resources at the VM. Tweak as needed
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2560", "--ioapic", "on", "--cpus", "2", "--chipset", "ich9", ]
  end

  config.vm.provision "shell", path: "shell/librarian.sh"
  
  # Hand off to puppet
  # config.vm.provision :puppet, :options => [""] do |puppet|
  #   puppet.manifests_path = "puppet/manifests"
  #   puppet.manifest_file  = "site.pp"
  #   puppet.module_path = "puppet/modules"
  #   puppet.hiera_config_path = "puppet/hiera.yaml"
  # 
  #   # some facts
  #   puppet.facter = {
  #     "drupal_siteinfo" => drupal_sites.to_json,
  #   }
  # end
end