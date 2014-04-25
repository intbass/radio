Development Radio
=================

You want to run your own radio station?

Start by installing [vagrant](vagrantup.com)

$ vagrant up

This will do the following;

* Download an image of the freebsd-10.0 operating system
* Configure it with 3 network interfaces (nat, host-only and bridged)
* NFS mount the current directory on the host as guest:/usr/home/vagrant/host
* prompt you for the music directory on the host and NFS mount that as guest:/music
* Install and run a [provision]() script
  The provision script uses [anisble]() on the guest to install and configure the software needed, 
  it should be safe to run multiple times to always end up at the same result.



