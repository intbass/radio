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
      host.vm.box = "mokote/debian-7"
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
    # nginx proxy
    config.vm.define "nginx-dev" do |host|
      host.vm.box = "mokote/debian-7"
      host.vm.hostname = "nginx-dev"
      if ENV['vagrantnic']
        host.vm.network :public_network, type: :dhcp, bridge: ENV['vagrantnic']
      else
        host.vm.network :public_network, type: :dhcp
      end
      host.vm.network "private_network", ip: "192.168.56.202"
      host.vm.network "private_network",
        virtualbox__intnet: "intbass-svcs",
        ip: "172.20.0.1"
      host.vm.provider :virtualbox do |vb|
        vb.name = "nginx-dev"
        vb.gui = VB_GUI
        vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
        vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
        vb.customize ["modifyvm", :id, "--nictype3", "virtio"]
        vb.customize ["modifyvm", :id, "--nictype4", "virtio"]
        vb.customize ["modifyvm", :id, "--memory", 1024]
      end
    end
    config.vm.provision 'ansible' do |ansible|
      ansible.playbook = 'playbook.yml'
      ansible.groups = {
        'vagrant' => ['radio-dev', 'nginx-dev'],
        'radio' => ['radio-dev' ],
        'nginx' => ['nginx-dev']
      }
    end
end
