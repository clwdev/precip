#!/bin/sh

# Restart Apache and MySQL.
service apache2 restart
service mysql restart

# Start cachefilesd service.
# Note: Two attempts are made to start the service,
# as the first attempt may not succeed.
systemctl stop cachefilesd
if ! ps ax | grep -v grep | grep cachefilesd > /dev/null
then
    systemctl start cachefilesd
    if ! ps ax | grep -v grep | grep cachefilesd > /dev/null
    then
        systemctl stop cachefilesd
        systemctl start cachefilesd
    fi
fi
