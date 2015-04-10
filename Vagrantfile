# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative 'vagrant/vars.rb'
require_relative 'vagrant/ansible.rb'
install_ansible

Vagrant.configure(2) do |config|
  config.vm.define "radio-dev" do |host|
    host.vm.hostname = 'radio-dev.intbass.com'
    host.vm.box = 'mokote/debian-7'
    host.vm.network :public_network, type: :dhcp
    host.vm.provider :virtualbox do |vb|
      vb.name = 'radio-dev'
      vb.gui = false
      vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
      vb.memory = 2048
      vb.cpus = 2
    end
  
    host.vm.synced_folder '.', '/vagrant', disabled: true, id: 'vagrant-root'
    host.vm.synced_folder '.', '/home/vagrant/host', id: 'vagrant-root'
    host.vm.synced_folder music, '/music', id: 'vagrant-music'
  
    host.vm.provision 'ansible' do |ansible|
      ansible.playbook = 'playbook.yml'
      ansible.groups = {
        'vagrant' => ['radio-dev'],
        'radio' => ['radio-dev'],
      }
    end
  end
end
