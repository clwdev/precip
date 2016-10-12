#!/bin/bash
service mysql stop
rm -rf /var/lib/mysql/*
cp -Rp /var/lib/mysql-old/* /var/lib/mysql
service mysql start