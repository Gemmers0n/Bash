#NGINX CONFIGURATION
#Matthias van Gemmern
#2017-11-06


. nginx.conf


apt-get update
apt-get install nginx -y

if [ -f /etc/nginx/nginx.conf.orig ]
then
	  echo "Original config already copied"
else
	  cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
fi

mkdir /etc/nginx/ssl
##todo quiet generating
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/$URL.duckdns.org.key -out /etc/nginx/ssl/$URL.duckdns.org.crt -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"

#number of cores "worker_processes auto;" todo if or nproc ... currently one core for older rpi
sed -i.bak 's/\(worker_processes \).*/\11\;/' /etc/nginx/nginx.conf
sed -i.bak 's/\(ssl_protocols \).*/\1TLSv1\.2\;/' /etc/nginx/nginx.conf
sed -i.bak 's/\(gzip \).*/\1off\;/' /etc/nginx/nginx.conf


systemctl restart nginx
systemctl enable nginx
