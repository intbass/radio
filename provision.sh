#!/bin/sh
cd $(dirname $(realpath "$0"))
if [ -f "roles/${1}.yml" ]
then
    BOOK="roles/${1}"
else
    BOOK="site"
fi
VARS=""
if [ -f "vars/$(hostname).yml" ]
then
  VARS="-e @./vars/$(hostname).yml"
fi
ansible-playbook --limit localhost -c local -i hosts ${VARS} ${BOOK}.yml
