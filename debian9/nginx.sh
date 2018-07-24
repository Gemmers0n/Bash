#!/bin/bash
#NGINX CONFIGURATION
#requires: none
#Matthias van Gemmern
#2018-07-24


#install packages
sudo apt-get update && sudo apt-get install -y nginx

#copy original config
if [ -f /etc/nginx/nginx.conf.orig ]
then
	  echo "Original config already copied"
else
	  cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
fi

#generate structure
sudo mkdir /etc/nginx/ssl
sudo openssl dhparam -out /etc/nginx/dhparam.pem 4096
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx-selfsigned.key -out /etc/nginx/ssl/nginx-selfsigned.crt -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com"

#modify config
sudo echo "server_tokens off;" >> /etc/nginx/nginx.conf

#restart and enable service autostart
systemctl restart nginx
systemctl enable nginx
