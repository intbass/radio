# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative 'vagrant/vars.rb'
require_relative 'vagrant/ansible.rb'
install_ansible

Vagrant.configure(2) do |host|
  host.vm.define "radio-dev" do |radio|
    radio.vm.hostname = 'radio-dev.intbass.com'
    radio.vm.box = 'mokote/debian-7'
    radio.vm.network :public_network, type: :dhcp
    radio.vm.provider :virtualbox do |vb|
      vb.name = 'radio-dev'
      vb.gui = false
      vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
      vb.memory = 2048
      vb.cpus = 2
    end
  
    radio.vm.synced_folder '.', '/vagrant', disabled: true, id: 'vagrant-root'
    radio.vm.synced_folder '.', '/home/vagrant/host', id: 'vagrant-root'
    radio.vm.synced_folder music, '/music', id: 'vagrant-music'
  
    radio.vm.provision 'ansible' do |ansible|
      ansible.playbook = 'playbook.yml'
      ansible.groups = {
        'vagrant' => ['radio-dev'],
        'radio' => ['radio-dev'],
      }
    end
  end
end
