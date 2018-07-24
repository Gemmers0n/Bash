#!/bin/bash
#TEAMSPEAK3-INSTALL
#Architecture x86-64
#requires: none
#Matthias van Gemmern
#2018-07-24


#VARS
#TEAMSPEAK_VERSION="3.0.13.8"
#TEAMSPEAK_VERSION="3.1.3"
TEAMSPEAK_VERSION="3.2.0"
TEAMSPEAK_INSTALLDIR="/opt"
TEAMSPEAK_FRESHINSTALL="YES"


#USER
adduser --disabled-password --gecos "" teamspeak


#SERVICE
systemctl stop teamspeak3server
#go sure ts3 is down
pkill ts3server
#clear shared memory
rm -f /dev/shm/7gbhujb54g8z9hu43jre8
if [ "$TEAMSPEAK_FRESHINSTALL" == "YES" ]; then
    rm -Rf $TEAMSPEAK_INSTALLDIR/teamspeak-server
fi


#SYSTEMD-SCRIPT
cat << EOF > /etc/systemd/system/teamspeak3server.service
[Unit]
Description=Teamspeak 3 Server
[Service]
ExecStart=/opt/teamspeak-server/ts3server_startscript.sh start
ExecStop=/opt/teamspeak-server/ts3server_startscript.sh stop
PIDFile=/opt/teamspeak-server/ts3server.pid
Type=forking
User=teamspeak
Group=teamspeak
[Install]
WantedBy=multi-user.target
EOF

chmod 755 /etc/systemd/system/teamspeak3server.service
sudo systemctl daemon-reload
sudo systemctl enable teamspeak3server.service


if [ "$TEAMSPEAK_FRESHINSTALL" == "YES" ]; then
    #SUDO
    echo "teamspeak ALL=NOPASSWD: /bin/systemctl start teamspeak3server, /bin/systemctl stop teamspeak3server, /bin/systemctl restart teamspeak3server, /bin$
fi


#INSTALL
mkdir $TEAMSPEAK_INSTALLDIR/teamspeak-server
wget http://dl.4players.de/ts/releases/$TEAMSPEAK_VERSION/teamspeak3-server_linux_amd64-$TEAMSPEAK_VERSION.tar.bz2 --directory-prefix=$TEAMSPEAK_INSTALLDIR
tar xfvj $TEAMSPEAK_INSTALLDIR/teamspeak3-server_linux_amd64-$TEAMSPEAK_VERSION.tar.bz2 -C $TEAMSPEAK_INSTALLDIR/teamspeak-server --strip 1
touch $TEAMSPEAK_INSTALLDIR/teamspeak-server/.ts3server_license_accepted
chown -R teamspeak:teamspeak $TEAMSPEAK_INSTALLDIR/teamspeak-server
chmod 0770 $TEAMSPEAK_INSTALLDIR/teamspeak-server


#CLEANUP
rm $TEAMSPEAK_INSTALLDIR/teamspeak3-server_linux_amd64-$TEAMSPEAK_VERSION.tar.bz2


#SERVICE
if [ "$TEAMSPEAK_FRESHINSTALL" == "YES" ]; then
    #may need some rework
    sudo -H -u teamspeak bash -c '/opt/teamspeak-server/ts3server_startscript.sh start'
    #go sure ts3 is down
    pkill ts3server
    #clear shared memory
    rm -f /dev/shm/7gbhujb54g8z9hu43jre8
fi
systemctl start teamspeak3server
