# -*- mode: ruby; -*-

require './vagrant/vars.rb'

Vagrant.configure("2") do |config|
  config.vm.guest = :freebsd
  config.vm.box = "chef/freebsd-10.0"

  config.vm.provider :virtualbox do |vb|
  #  vb.customize ["startvm", :id, "--type", "gui"]
    vb.customize ["modifyvm", :id, "--memory", "512"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
    vb.customize ["modifyvm", :id, "--nictype3", "virtio"]
  end
 
  config.vm.hostname = "dev.beats.to"
  config.vm.network "private_network", type: :dhcp
  config.vm.network "public_network", type: :dhcp, :bridge => 'wlan0'
  # Use NFS as a shared folder
  config.vm.synced_folder ".", "/vagrant", disabled: true, id: "vagrant-root"
  config.vm.synced_folder ".", "/home/vagrant/host/", :nfs => true, id: "vagrant-root", :mount_options => ['nolock,vers=3,udp']
  config.vm.synced_folder music(), "/music/", :nfs => true, id: "vagrant-music", :mount_options => ['nolock,vers=3,udp']

  config.vm.provision "shell", path: 'vagrant/provision' 
  config.ssh.shell = "csh"
end
