# -*- mode: ruby -*-
# vi: set ft=ruby :

VB_GUI=false

# To automatically bind the NAT interface to a particular interface on the
# local machine, set ENV['vagrantnic'] in your ~/.vagrant.d/Vagrantfile

require_relative 'vagrant/ansible.rb'
install_ansible

Vagrant.configure(2) do |config|
    # radio
    config.vm.define "radio-dev" do |host|
      host.vm.box = "mokote/debian-8"
      host.vm.hostname = "radio-dev"
      if ENV['vagrantnic']
        host.vm.network :public_network, type: :dhcp, bridge: ENV['vagrantnic']
      else
        host.vm.network :public_network, type: :dhcp
      end
      host.vm.network "private_network", ip: "192.168.56.201"
      host.vm.provider :virtualbox do |vb|
        vb.name = "radio-dev"
        vb.gui = VB_GUI
        vb.memory = 1024
        vb.cpus = 2
        vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
        vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
        vb.customize ["modifyvm", :id, "--nictype3", "virtio"]
      end
    end
    config.vm.provision 'ansible' do |ansible|
      if ENV.key?('TAGS') then
        ansible.tags = ENV['TAGS']
      end
      ansible.playbook = 'playbook.yml'
      ansible.groups = {
        'vagrant' => ['radio-dev'],
        'radio' => ['radio-dev' ]
      }
    end
end
