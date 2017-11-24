#NGINX CONFIGURATION
#tested in debian8
#Matthias van Gemmern
#2017-11-06


#include config
. nginx.conf

#install packages
apt-get update
apt-get install -y nginx

#copy original config
if [ -f /etc/nginx/nginx.conf.orig ]
then
	  echo "Original config already copied"
else
	  cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
fi

#generate structure
mkdir /etc/nginx/ssl
##todo quiet generating
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/$URL.duckdns.org.key -out /etc/nginx/ssl/$URL.duckdns.org.crt -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"

#modify config
##todo number of cores "worker_processes auto;" todo if or nproc ... currently one core for older rpi
sed -i.bak 's/\(worker_processes \).*/\11\;/' /etc/nginx/nginx.conf
sed -i.bak 's/\(ssl_protocols \).*/\1TLSv1\.2\;/' /etc/nginx/nginx.conf
sed -i.bak 's/\(gzip \).*/\1off\;/' /etc/nginx/nginx.conf
#TODO keepalive_timeout   2; in nginx.conf

#restart and enable service autostart
systemctl restart nginx
systemctl enable nginx
