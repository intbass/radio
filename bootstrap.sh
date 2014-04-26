#!/usr/local/bin/bash
# bootstrap ansible
test -z $(pkg info ansible 2>/dev/null | head -n 1) && sudo pkg install -y ansible
# install provisioner link if not present
if ! [ -f /usr/local/bin/provision ]
then
    sudo ln -s $(dirname $(realpath "$0"))"/provision.sh" /usr/local/bin/provision
fi
# check provisioner is runnable
if ! [ -x /usr/local/bin/provision ]
then
    sudo chmod +x /usr/local/bin/provision
fi
# run the provisioner
sudo /usr/local/bin/provision

