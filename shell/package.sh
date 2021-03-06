#!/bin/sh
# Package up this vagrant box for distribution.
# Usage: sudo bash package.sh

echo "THIS WILL DESTROY AND RECREATE YOUR VAGRANT BOX."
echo "It is NOT reccomended that you do this using your development environment."
read -p "Are you sure you still want to do this? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit
fi

BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd "$BASEDIR/.."

echo "Ensuring a clean machine"
vagrant destroy --force

echo "Prepping config.rb and sites folder"
# cp config.rb-dist config.rb
# echo "packaging_mode = true" | tee -a config.rb
# mkdir -p "$BASEDIR/../sites" >/dev/null 2>&1

echo "Setting up Vagrant"
# sudo touch /etc/exports
vagrant up
vagrant halt

echo "Packaging Vagrant"
rm -rf precip.box >/dev/null 2>&1
vagrant ssh -c "sudo apt-get clean && cat /dev/null > ~/.bash_history && history -c"
vagrant package --output precip.box

echo "Cleaning up"
vagrant destroy --force