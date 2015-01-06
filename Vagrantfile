# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative 'vagrant/vars.rb'
require_relative 'vagrant/ansible.rb'

Vagrant.configure(2) do |host|
  host.vm.hostname = 'dev.beats.to'
  host.vm.box = 'zimbatm/nixbox64'
  host.vm.network :public_network, type: :dhcp
  host.vm.provider :virtualbox do |vb|
    vb.gui = true
    vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
    vb.memory = 2048
    vb.cpus = 2
  end

  # Add the htop package
  host.vm.provision :nixos, :expression => {
    environment: {
      systemPackages: [:vim]
    }
  }

  host.vm.synced_folder '.', '/vagrant', disabled: true, id: 'vagrant-root'
  host.vm.synced_folder '.', '/home/vagrant/host', id: 'vagrant-root'
  host.vm.synced_folder music, '/music', id: 'vagrant-music'
end
