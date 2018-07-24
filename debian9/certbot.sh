#!/bin/bash
#CERTBOT INSTALL AND LETSENCRYPT CERTREQ
#requires: nginx.sh
#Matthias van Gemmern
#2018-07-24


#INCLUDE
. certbot.conf

#INSTALL
sudo echo "deb http://ftp.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/stretch-backports.list
sudo apt-get update && sudo apt-get install -y python-certbot-nginx -t stretch-backports

#CONFIG
sudo certbot --authenticator nginx --installer nginx --domains $DOMAIN --renew-by-default --agree-tos --no-eff-email -m "$EMAIL" --break-my-certs --no-redirect
