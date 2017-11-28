#LETSENCRYPT CONFIGURATION
#Matthias van Gemmern
#2017-11-23


#include config
. letsencrypt.conf

DOMAIN2=$URL.duckdns.org
#generate structure
##todo variable
cd /root/
curl --silent https://raw.githubusercontent.com/srvrco/getssl/master/getssl > getssl ; chmod 700 getssl
./getssl -c $DOMAIN2
echo "ACCOUNT_EMAIL=\"$MAIL\"" >> /root/.getssl/getssl.cfg
echo "ACL=('/root/letsencrypt_server/.well-known/acme-challenge'" >> /root/.getssl/$URL.duckdns.org/getssl.cfg
echo "'/root/letsencrypt_server/.well-known/acme-challenge')" >> /root/.getssl/$URL.duckdns.org/getssl.cfg
mkdir -p /root/letsencrypt_server/.well-known/acme-challenge
#TODO uncomment real certificate server

service nginx stop

#get certificate
cd /root/letsencrypt_server
python -m SimpleHTTPServer 80&
cd ..
./getssl $DOMAIN2
pkill python
cp .getssl/$URL.duckdns.org/$URL.duckdns.org.* /etc/nginx/ssl/
cat /root/.getssl/$URL.duckdns.org/$URL.duckdns.org.crt /root/.getssl/$URL.duckdns.org/chain.crt > /etc/nginx/ssl/$URL.duckdns.org.chain.crt
cat /root/.getssl/$URL.duckdns.org/$URL.duckdns.org.crt /root/.getssl/$URL.duckdns.org/$URL.duckdns.org.key > /etc/nginx/ssl/$URL.duckdns.org.pem

# start service
service nginx start
