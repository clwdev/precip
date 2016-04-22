#!/bin/sh
# Package up this vagrant box for distribution.
# Usage: sudo bash package.sh

BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo "Ensuring a clean machine"
vagrant destroy --force

cd "$BASEDIR/.."
cp config.rb-dist config.rb

echo "Installing prerequirements"
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-hostsupdater
vagrant plugin install vagrant-useradd
vagrant plugin install vagrant-bindfs

echo "Setting up Vagrant"
sudo touch /etc/exports
vagrant up
vagrant halt

echo "Packaging Vagrant"
vagrant package --base precip --output precip.box

echo "Cleaning up"
vagrant destroy --force