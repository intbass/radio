Development Radio
=================

You want to run your own radio station?

Prerequsites
------------

* [vagrant](http://vagrantup.com/)
* [python](https://www.python.org/)
* [virtualenv](https://virtualenv.pypa.io/en/latest/installation.html)
* [git](http://git-scm.com/)

Development
-----------

$ git clone https://github.com/beats-to/radio.git
$ cd radio
$ vagrant up

This will do the following;

* Download a Centos 7 vm image
* Configure it with 2 network interfaces (nat and bridged)
* mount the current directory on the host as guest:/vagrant/
#* prompt you for the music directory on the host and NFS mount that as guest:/music
* Create a local python virtualenv
* Install and update once a month the ansible install
* Run the ansible provisioner against the guest

Environment
-----------

ANSIBLAB is used to set the ansible verbosity.
TAGS is used to selectively apply ansible plays.

any ansible configuration values can be overridden in group_vars/local.yml



