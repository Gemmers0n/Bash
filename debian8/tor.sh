#TOR CONFIGURATION
#tested in debian8
#Matthias van Gemmern
#2017-11-23


#include config
. tor.conf

#install packages
apt-get update
apt-get install -y tor

#copy original config
if [ -f /etc/tor/torrc.orig ]
then
	  echo "Original config already copied"
else
	  cp /etc/tor/torrc /etc/tor/torrc.orig
fi

#generate structure
mkdir /var/lib/tor/hidden_service
chown debian-tor:debian-tor /var/lib/tor/hidden_service
chmod 0700 /var/lib/tor/hidden_service

#modify config
echo "HiddenServiceDir /var/lib/tor/hidden_service/" > /etc/tor/torrc
echo "HiddenServicePort $PORT `ip a s eth0 | awk '/inet / {print$2}' | cut -d/ -f1`:$PORT" >> /etc/tor/torrc

#restart and enable service autostart
systemctl restart tor
systemctl enable tor
