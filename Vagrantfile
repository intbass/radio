# -*- mode: ruby; -*-

require File.dirname(__FILE__) + '/vagrant/vars.rb'
require File.dirname(__FILE__) + '/vagrant/net.rb'

Vagrant.configure("2") do |config|
  config.vm.guest = :freebsd
  config.vm.box = "chef/freebsd-10.0"

  config.vm.provider :virtualbox do |vb|
    if isdefined('gui')
      vb.customize ["startvm", :id, "--type", "gui"]
    end
    vb.customize ["modifyvm", :id, "--memory", "512"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
    vb.customize ["modifyvm", :id, "--nictype3", "virtio"]
  end
 
  config.vm.hostname = "dev.beats.to"
  network config.vm, "private"
  network config.vm, "public"
  # Use NFS as a shared folder
  # I dislike /vagrant b/c /var
  config.vm.synced_folder ".", "/vagrant", disabled: true, id: "vagrant-root"
  config.vm.synced_folder ".", "/home/vagrant/host/", :nfs => true, id: "vagrant-root", :mount_options => ['nolock,vers=3,udp']
  config.vm.synced_folder music(), "/music/", :nfs => true, id: "vagrant-music", :mount_options => ['nolock,vers=3,udp']

  config.vm.provision "shell", inline: '/bin/sh /home/vagrant/host/bootstrap.sh'
  config.ssh.shell = "csh"
end
