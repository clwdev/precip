#!/bin/sh
# Cleanly install Precip on OSX, including dependencies.
#
# After you clone the repo, run ```bash setup-osx.sh```
#
# Warning: This forcibly destroys and re-creates the vagrant box.
# This could also be somewhat distructive if preexisting virtual machines
# you have running require different plugin version dependencies.

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'
BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
function out {
  echo ; echo -e "${GREEN}$1${NC}"
}

out "Installing Precip for OSX."

cd "$BASEDIR/.."
if [ -f "config.rb" ]
then
  out "Existing config.rb found."
else
  cp config.rb-dist config.rb
  echo ; echo -e "${YELLOW}You will need to edit your config.rb!${NC}"
fi

# Check if Vagrant is already installed, and if so shut down all VMs.
if [ "$(which vagrant)" != "" ]
then
  out "Shutting down any virtual machines currently running."
  vagrant global-status | grep virtualbox | cut -c 1-9 | while read line; do echo $line; vagrant halt $line; done;
fi

# Ensure we have Homebrew.
if [ "$(which brew)" == "" ]
then
  if [ "$(which ruby)" == "" ]
  then
    out "Installing Xcode-select."
    xcode-select --install
  fi

  out "Installing Homebrew."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null
fi

out "Updating brew."
brew update

if [[ "$(brew cask --version)" == *"git revision"* ]]
then
  echo "Cask found."
else
  out "Installing Cask."
  brew tap phinze/homebrew-cask
  brew install phinze/cask/brew-cask
fi

out "Installing Virtualbox."
brew cask install virtualbox

out "Installing Vagrant."
brew cask install vagrant

out "Installing required Vagrant plugins."
# Clean up previous Vagrant plugins first to prevent version conflicts.
rm -r ~/.vagrant.d/plugins.json ~/.vagrant.d/gems
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-hostsupdater
vagrant plugin install vagrant-useradd
vagrant plugin install vagrant-bindfs

out "Ensuring a clean machine."
vagrant destroy --force

out "Setting up Vagrant."
# This shouldn't be needed with newer versions of Vagrant:
# sudo touch /etc/exports
rm -rf ~/.vagrant.d/tmp/ 2>&1
vagrant up
vagrant up

out "Installing Vagrant Manager."
brew cask install vagrant-manager
open ~/Applications/"Vagrant Manager.app"
