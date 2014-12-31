# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
config = {}
begin
  config = YAML.load_file('group_vars/local.yml')
rescue NoMethodError, IOError, Errno::ENOENT
  puts 'No local variables found'
end

# Install an isolated copy of python to run ansible
def install_venv(venv)
  File.directory?(venv) || `virtualenv venv`
  ENV['VIRTUAL_ENV'] = venv
  ENV['PATH'] = File.join(venv, 'bin') + ':' + ENV['PATH']
end

# Install ansible in the isolated environment
def pip_ansible(venv)
  ansibin = File.join(venv, 'bin', 'ansible')
  File.executable?(ansibin) || `#{venv}/bin/pip install ansible docker-py`
end

# Upgrade ansible every monthish
def pip_upgrade(venv)
  stat = File.stat(venv)
  Date.parse(stat.mtime.to_s) > Date.today - 30 && return
  `#{venv}/bin/pip install --upgrade`
  FileUtils.touch venv
end

def install_ansible
  local = File.dirname(File.expand_path(__FILE__))
  venv  = File.join(local, 'venv')
  install_venv(venv)
  pip_ansible(venv)
  pip_upgrade(venv)
end
install_ansible

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
    ansible.playbook = 'playbook.yml'
    ENV.key?('TAGS') && ansible.tags = ENV['TAGS']
    ENV.key?('ANSIBLAB') && ansible.verbose = ENV['ANSIBLAB']
    ansible.extra_vars = config
  end
end
