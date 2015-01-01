# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative 'vagrant/vars.rb'
require_relative 'vagrant/ansible.rb'

Vagrant.configure(2) do |host|
  host.vm.hostname = 'dev.beats.to'
  host.vm.box = 'box-cutter/centos70-docker'
  host.vm.network :public_network, type: :dhcp
  host.vm.provider :virtualbox do |vb|
    vb.gui = true
    vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
    vb.memory = 2048
    vb.cpus = 2
  end

  host.vm.provision 'ansible' do |ansible|
    install_ansible
    ansible.playbook = 'playbook.yml'
    ENV.key?('TAGS') && ansible.tags = ENV['TAGS']
    ENV.key?('ANSIBLAB') && ansible.verbose = ENV['ANSIBLAB']
    ansible.extra_vars = ansible_config
  end

  host.vm.synced_folder '.', '/vagrant', disabled: true, id: 'vagrant-root'
  host.vm.synced_folder '.', '/host', id: 'vagrant-root'
  host.vm.synced_folder music, '/music', id: 'vagrant-music'
end
