#!/bin/bash
echo "Installing @vm.* Drush Aliases..."
mkdir -p $HOME/.drush
if [ -e "vm.aliases.drushrc.php" ]; then
  cp -f vm.aliases.drushrc.php $HOME/.drush/
  echo -e "Done! Here they are: \n"
  drush sa @vm
else
  echo "No aliases file. Edit config.rb and $ vagrant provision first."
fi