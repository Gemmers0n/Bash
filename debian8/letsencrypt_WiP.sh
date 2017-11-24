#LETSENCRYPT CONFIGURATION
#Matthias van Gemmern
#2017-11-23


#include config
. letsencrypt.conf

#generate structure
##todo variable
cd /root/
curl --silent https://raw.githubusercontent.com/srvrco/getssl/master/getssl > getssl ; chmod 700 getssl
./getssl -c $DOMAIN.duckdns.org
echo "ACCOUNT_EMAIL=\"$MAIL\"" >> /root/.getssl/getssl.cfg
echo "ACL=('/root/letsencrypt_server/.well-known/acme-challenge'" >> /root/.getssl/$DOMAIN.duckdns.org/getssl.cfg
echo "'/root/letsencrypt_server/.well-known/acme-challenge')" >> /root/.getssl/$DOMAIN.duckdns.org/getssl.cfg
mkdir -p /root/letsencrypt_server/.well-known/acme-challenge

service nginx stop

#get certificate
cd /root/letsencrypt_server
python -m SimpleHTTPServer 80&
cd ..
./getssl $DOMAIN.duckdns.org
pkill python
cp .getssl/$DOMAIN.duckdns.org/$DOMAIN.duckdns.org.* /etc/nginx/ssl/
cat /root/.getssl/$DOMAIN.duckdns.org/$DOMAIN.duckdns.org.crt /root/.getssl/$DOMAIN.duckdns.org/chain.crt > /etc/nginx/ssl/$DOMAIN.duckdns.org.chain.crt

# start service
service nginx start
