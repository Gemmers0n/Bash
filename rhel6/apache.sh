#!/bin/bash
#APACHE CONFIGURATION RHEL6
#Matthias van Gemmern
#2018-05-23


#include config
. apache.conf

#install packages
yum install httpd mod_ssl -y

#copy original config
if [ -f /etc/httpd/conf/httpd.conf ]
then
	  echo "Original config already copied"
else
	  cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.orig
fi

#generate structure
mkdir /etc/httpd/ssl
mkdir /etc/httpd/sites-available /etc/httpd/sites-enabled

#generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/httpd/ssl/$URL.key -out /etc/httpd/ssl/$URL.crt -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"

#modify config
echo "Include /etc/httpd/sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf
openssl dhparam -out /etc/httpd/dhparam.pem 4096

#restart and enable service autostart
chkconfig httpd on
service start httpd
