
#BASIC RPI CONFIGURATION
#Matthias van Gemmern
#2017-11-23


#include config
. firefox_sync.conf

#install packages
apt-get install -y python-dev git-core python-virtualenv screen

cd /opt
git clone https://github.com/mozilla-services/syncserver
cd syncserver
make build
cat /opt/syncserver/syncserver.ini |grep -v "^#"|grep -v "^public_url = " > /opt/syncserver/syncserver.ini.new
echo "public_url = http://$HOSTNAME.duckdns.org:5000/" >> /opt/syncserver/syncserver.ini.new
echo "sqluri = sqlite:////external/firefoxsync/file.db" >> /opt/syncserver/syncserver.ini.new
echo "secret = `head -c 20 /dev/urandom | sha1sum|cut -d' ' -f1`" >> /opt/syncserver/syncserver.ini.new
echo "allow_new_users = true" >> /opt/syncserver/syncserver.ini.new

useradd firefoxsync -s /bin/false
chown -R firefoxsync:firefoxsync /opt/syncserver
ln -s /opt/syncserver/local/bin/pserve /usr/bin/pserve
mv /opt/syncserver/syncserver.ini.new /opt/syncserver/syncserver.ini
#database directory
mkdir /external/firefoxsync
chown firefoxsync:firefoxsync /external/firefoxsync/

#make crontab file
echo "@reboot firefoxsync screen -dmS firefoxSyncServer pserve /opt/syncserver/syncserver.ini" >> /etc/cron.d/firefoxsync
chmod 644 /etc/cron.d/firefoxsync
