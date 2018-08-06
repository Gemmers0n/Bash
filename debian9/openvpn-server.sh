#!/bin/bash
#OPENVPN-SERVER
#requires: none
#Matthias van Gemmern
#2018-07-24


#INSTALL
sudo apt-get update && sudo apt-get install -y openvpn easy-rsa

#CONFIG
##openvpn config
###config
sudo gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz > /etc/openvpn/server.conf
echo 'push "redirect-gateway def1 bypass-dhcp"' >> /etc/openvpn/server.conf
echo 'push "dhcp-option DNS 208.67.222.222"' >> /etc/openvpn/server.conf
echo 'push "dhcp-option DNS 208.67.220.220"' >> /etc/openvpn/server.conf
echo 'user nobody' >> /etc/openvpn/server.conf
echo 'group nogroup' >> /etc/openvpn/server.conf
###dirs
mkdir /etc/openvpn/easy-rsa/keys
cp -r /usr/share/easy-rsa/ /etc/openvpn
###sysconfig
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
###generating
openssl dhparam -out /etc/openvpn/dh2048.pem 2048
cd /etc/openvpn/easy-rsa
ln -s openssl-1.0.0.cnf openssl.cnf
. ./vars
./clean-all
./build-ca EasyRSA ##Anderer Key Name, wenn kein Standard genommen wurde ##kein pw vergeben am ende zwei mal y
cp /etc/openvpn/easy-rsa/keys/EasyRSA.crt /etc/openvpn/server.crt # wieder name beachten
cp /etc/openvpn/easy-rsa/keys/EasyRSA.key /etc/openvpn/server.key # wieder name beachten
cp /etc/openvpn/easy-rsa/keys/ca.crt /etc/openvpn 
openvpn --genkey --secret /etc/openvpn/ta.key


#SERVICE
systemctl enable openvpn
systemctl start openvpn


#GENERATE CLIENT CERT
cd /etc/openvpn/easy-rsa
. ./vars #sets env
./build-key $KEYNAME
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/easy-rsa/keys/client.ovpn
nano /etc/openvpn/easy-rsa/keys/client.ovpn
-->
remote $OPENVPN-SERVER $OPENVPN-SERVER-PORT
user nobody
group nogroup
<--
nano /etc/openvpn/easy-rsa/keys/client.ovpn
-->
;ca ca.crt
;cert client.crt
;key client.key
;tls-auth ta.key 1
<--
echo 'key-direction 1' >> /etc/openvpn/easy-rsa/keys/client.ovpn
echo '<tls-auth>' >> /etc/openvpn/easy-rsa/keys/client.ovpn
cat /etc/openvpn/ta.key >> /etc/openvpn/easy-rsa/keys/client.ovpn
echo '</tls-auth>' >> /etc/openvpn/easy-rsa/keys/client.ovpn
echo '<ca>' >> /etc/openvpn/easy-rsa/keys/client.ovpn
cat /etc/openvpn/ca.crt >> /etc/openvpn/easy-rsa/keys/client.ovpn
echo '</ca>' >> /etc/openvpn/easy-rsa/keys/client.ovpn
echo '<cert>' >> /etc/openvpn/easy-rsa/keys/client.ovpn
cat /etc/openvpn/easy-rsa/keys/$KEYNAME.crt >> /etc/openvpn/easy-rsa/keys/client.ovpn
echo '</cert>' >> /etc/openvpn/easy-rsa/keys/client.ovpn
echo '<key>' >> /etc/openvpn/easy-rsa/keys/client.ovpn
cat /etc/openvpn/easy-rsa/keys/$KEYNAME.key >> /etc/openvpn/easy-rsa/keys/client.ovpn
echo '</key>' >> /etc/openvpn/easy-rsa/keys/client.ovpn
cp /etc/openvpn/easy-rsa/keys/client.ovpn /home/admin/
chown admin:admin /home/admin/client.ovpn 
##TODO export via scp----------------->
