apt-get install python-dev git-core python-virtualenv screen -y
cd /opt
sudo git clone https://github.com/mozilla-services/syncserver
cd syncserver
sudo make build
cat /opt/syncserver/syncserver.ini |grep -v "^#"|grep -v "^public_url = " > /opt/syncserver/syncserver.ini.new
echo "public_url = http://$HOSTNAME.duckdns.org:5000/" >> /opt/syncserver/syncserver.ini.new
mkdir /external/firefoxsync
chown firefoxsync:firefoxsync /external/firefoxsync/
echo "sqluri = sqlite:////external/firefoxsync/file.db" >> /opt/syncserver/syncserver.ini.new
echo "secret = `head -c 20 /dev/urandom | sha1sum|cut -d' ' -f1`" >> /opt/syncserver/syncserver.ini.new
echo "allow_new_users = true" >> /opt/syncserver/syncserver.ini.new
useradd firefoxsync -s /bin/false
sudo chown -R firefoxsync:firefoxsync /opt/syncserver
sudo ln -s /opt/syncserver/local/bin/pserve /usr/bin/pserve
mv /opt/syncserver/syncserver.ini.new /opt/syncserver/syncserver.ini
echo "@reboot firefoxsync screen -dmS firefoxSyncServer pserve /opt/syncserver/syncserver.ini" >> /etc/cron.d/firefoxsync
chmod 644 /etc/cron.d/firefoxsync