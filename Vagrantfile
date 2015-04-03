# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative 'vagrant/vars.rb'
require_relative 'vagrant/ansible.rb'
install_ansible

Vagrant.configure(2) do |host|
  host.vm.hostname = 'dev.intbass.com'
  host.vm.box = 'mokote/debian-7'
  host.vm.network :public_network, type: :dhcp
  host.vm.provider :virtualbox do |vb|
    vb.gui = true
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
      'vagrant' => ['default'],
    }
    # Default list of skip tags
    skip_tags = File.read(File.join($dir, 'skip_tags')).split(/\n/)
    # tags are defined
    if ENV.key?('TAGS') then
      # remove specified tags from default list of skips
      tags = ENV['TAGS'].split(/,/)
      tags.each do |tag|
        skip_tags.delete(tag)
      end
      # tell ansible about the specified tags
      ansible.tags = tags.join(',')
    end
    # specified skip tags has the last say
    ENV.key?('SKIP_TAGS') && skip_tags << ENV['SKIP_TAGS'].split(/,/)
    ansible.skip_tags = skip_tags.join(',')
    ENV.key?('ANSIBLAB') && ansible.verbose = ENV['ANSIBLAB']
    ansible.extra_vars = config
    password_file = File.join($dir, 'vault_pass.txt')
    if File.exists?(password_file) then
      ansible.vault_password_file = password_file
    else
      ansible.ask_vault_pass = "true"
    end
  end
end
