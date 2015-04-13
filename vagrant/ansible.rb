# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

def ansible_config
  config = {}
  begin
    config = YAML.load_file(File.dirname(__FILE__) + '/../group_vars/local.yml')
  rescue NoMethodError, IOError, Errno::ENOENT
    puts 'No local variables found'
  end
  return config
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
  File.executable?(ansibin) || `#{venv}/bin/pip install ansible markupsafe`
end

# Upgrade ansible every monthish
def pip_upgrade(venv)
  stat = File.stat(venv)
  Date.parse(stat.mtime.to_s) > Date.today - 30 && return
  `#{venv}/bin/pip install --upgrade`
  FileUtils.touch venv
end

# install ansible galaxy roles
def ansible_galaxy(local)
  venv  = File.join local, '..', 'venv'
  roles = File.join local, '..', 'roles'
  file  = File.join local, '..', 'galaxy-roles.txt'
  `#{venv}/bin/ansible-galaxy install -r #{file} -p #{roles}`
end

def install_ansible
  local = File.dirname File.expand_path __FILE__
  venv  = File.join local, '..', 'venv'
  install_venv venv
  pip_ansible venv
  pip_upgrade venv
  ansible_galaxy local
end
