#LETSENCRYPT CONFIGURATION
#Matthias van Gemmern
#2017-11-23


#include config
. letsencrypt.conf

#generate structure
##todo variable
cd /root/
curl --silent https://raw.githubusercontent.com/srvrco/getssl/master/getssl > getssl ; chmod 700 getssl
./getssl -c $DOMAIN
echo "ACCOUNT_EMAIL=\"$MAIL\"" >> /root/.getssl/getssl.cfg
echo "ACL=('/root/letsencrypt_server/.well-known/acme-challenge'" >> /root/.getssl/$DOMAIN/getssl.cfg
echo "'/root/letsencrypt_server/.well-known/acme-challenge')" >> /root/.getssl/$DOMAIN/getssl.cfg
mkdir -p /root/letsencrypt_server/.well-known/acme-challenge

service nginx stop

#get certificate
cd /root/letsencrypt_server
python -m SimpleHTTPServer 80&
cd ..
./getssl $DOMAIN
pkill python
cp .getssl/$DOMAIN/$DOMAIN.* /etc/nginx/ssl/
cat /root/.getssl/$DOMAIN/$DOMAIN.crt /root/.getssl/$DOMAIN/chain.crt > /etc/nginx/ssl/$DOMAIN.chain.crt

# start service
service nginx start
