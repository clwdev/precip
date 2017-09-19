#!/bin/sh

# Restart Apache and MySQL.
service apache2 restart
service mysql restart

# Start cachefilesd service.
# Note: Two attempts are made to start the service,
# as the first attempt may not succeed.
if ! ps ax | grep -v grep | grep cachefilesd > /dev/null
then
    service cachefilesd start
    if ! ps ax | grep -v grep | grep cachefilesd > /dev/null
    then
        service cachefilesd start
    fi
fi
