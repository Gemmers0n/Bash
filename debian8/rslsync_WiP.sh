#RESILIO SYNC RPI CONFIGURATION
#only working on RPI 2+
#Matthias van Gemmern
#2017-11-28


#include config
#TODO
#. rslsync.conf

#Install packages and patches
apt-get update

CONFIG='/etc/resilio-sync/config.json'

echo "deb [arch=armhf] http://linux-packages.resilio.com/resilio-sync/deb resilio-sync non-free" | sudo tee /etc/apt/sources.list.d/resilio-sync.list
wget -qO - https://linux-packages.resilio.com/resilio-sync/key.asc | sudo apt-key add -
#sudo dpkg --add-architecture armel #RPI1 
sudo dpkg --add-architecture armhf
sudo apt-get update
sudo apt-get install resilio-sync -y
#sudo apt-get install resilio-sync:armel RPI1

#create config
echo '{' > $CONFIG ;echo -n '  "device_name": "' >> $CONFIG ;echo -n `hostname` >> $CONFIG;echo '",' >> $CONFIG
echo '  "storage_path" : "/external/rslsync-data/",' >> $CONFIG
echo '  "pid_file" : "/var/run/resilio-sync/sync.pid",' >> $CONFIG
tail -n+5 conf/rslsync.conf >> $CONFIG

usermod -u 1010 rslsync

#restart and enable service autostart
sudo systemctl start resilio-sync
sudo systemctl enable resilio-sync
