#!/bin/sh
# Heavily Inspired By https://github.com/purple52/librarian-puppet-vagrant

echo "librarian-puppet - Checking dependencies..."
apt-get update > /dev/null 2>&1

if ! (which git > /dev/null 2>&1); then 
  apt-get -q -y install git > /dev/null 2>&1;
fi

if [ -n "$(apt-cache search ruby1.9.1-dev)" ]; then
  apt-get -q -y install ruby1.9.1-dev > /dev/null 2>&1;
fi

if ! (which librarian-puppet > /dev/null 2>&1); then 
  gem install librarian-puppet > /dev/null 2>&1;
fi

echo "librarian-puppet - Dependencies installed!"
cp -rf /vagrant/puppet/Puppetfile /etc/puppet/Puppetfile
cp -rf /vagrant/puppet/Puppetfile.lock /etc/puppet/Puppetfile.lock

echo "librarian-puppet - Installing Puppet Modules..."
cd /etc/puppet && librarian-puppet install

echo "librarian-puppet - Ready to provision!"