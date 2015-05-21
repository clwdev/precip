<?php
/*
 * Like phpMyAdmin? I won't hold it against you. Here's a PMA config file 
 * that'll work with Precip. Just download PMA from phpmyadmin.net, unzip it to 
 * /util/phpMyAdmin and copy this config.inc.php to the directory. Then load up 
 * http://precip.vm/phpMyAdmin and start using it.
 */

$cfg['Servers'][1]['auth_type'] = 'config';
$cfg['Servers'][1]['AllowNoPassword'] = true;
$cfg['Servers'][1]['host'] = 'localhost';
$cfg['Servers'][1]['user'] = 'root';
$cfg['Servers'][1]['nopassword'] = true;
$cfg['Servers'][1]['connect_type'] = 'tcp';
$cfg['Servers'][1]['compress'] = false;

$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';
$cfg['SessionSavePath'] = '/tmp'