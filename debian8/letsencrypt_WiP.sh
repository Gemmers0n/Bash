#LETSENCRYPT CONFIGURATION
#Matthias van Gemmern
#2017-11-23


#include config
. letsencrypt.conf

#todo confilcts with $DOMAIN from sub script
DOMAIN2=$URL.$TLD
#generate structure
##todo variable
cd /root/
curl --silent https://raw.githubusercontent.com/srvrco/getssl/master/getssl > getssl ; chmod 700 getssl
./getssl -c $DOMAIN2
echo "ACCOUNT_EMAIL=\"$MAIL\"" >> /root/.getssl/getssl.cfg
echo "ACL=('/root/letsencrypt_server/.well-known/acme-challenge'" >> /root/.getssl/$URL.$TLD/getssl.cfg
echo "'/root/letsencrypt_server/.well-known/acme-challenge')" >> /root/.getssl/$URL.$TLD/getssl.cfg
mkdir -p /root/letsencrypt_server/.well-known/acme-challenge
#TODO uncomment real certificate server

service nginx stop

#get certificate
cd /root/letsencrypt_server
python -m SimpleHTTPServer 80&
cd ..
./getssl $DOMAIN2
pkill python
cp .getssl/$URL.$TLD/$URL.$TLD.* /etc/nginx/ssl/
cat /root/.getssl/$URL.$TLD/$URL.$TLD.crt /root/.getssl/$URL.$TLD/chain.crt > /etc/nginx/ssl/$URL.$TLD.chain.crt

# start service
service nginx start
