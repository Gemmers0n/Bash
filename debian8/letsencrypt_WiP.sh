#LETSENCRYPT CONFIGURATION
#Matthias van Gemmern
#2017-11-06
#uses https://github.com/srvrco/getssl

LETSENCRYPT_HOME=/opt/letsencrypt
DOMAIN=gemmers0nkv.duckdns.org
service nginx stop

##todo variable
cd /root/
curl --silent https://raw.githubusercontent.com/srvrco/getssl/master/getssl > getssl ; chmod 700 getssl
./getssl -c gemmers0nkv.duckdns.org
echo "ACCOUNT_EMAIL=\"matthias.vangemmern@gmail.com\"" >> /root/.getssl/getssl.cfg
echo "ACL=('/root/letsencrypt_server/.well-known/acme-challenge'" >> /root/.getssl/gemmers0nkv.duckdns.org/getssl.cfg
echo "'/root/letsencrypt_server/.well-known/acme-challenge')" >> /root/.getssl/gemmers0nkv.duckdns.org/getssl.cfg
mkdir -p /root/letsencrypt_server/.well-known/acme-challenge
service nginx stop
cd /root/letsencrypt_server
python -m SimpleHTTPServer 80&
cd ..
./getssl gemmers0nkv.duckdns.org
pkill python
cp .getssl/gemmers0nkv.duckdns.org/gemmers0nkv.duckdns.org.* /etc/nginx/ssl/
cat /root/.getssl/gemmers0nkv.duckdns.org/gemmers0nkv.duckdns.org.crt /root/.getssl/gemmers0nkv.duckdns.org/chain.crt > /etc/nginx/ssl/gemmers0nkv.duckdns.org.chain.crt
service nginx start

