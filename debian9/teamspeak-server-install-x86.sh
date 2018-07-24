#!/bin/bash
#TEAMSPEAK3-INSTALL
#Architecture x86-64
#requires: none
#Matthias van Gemmern
#2018-07-24

#VARS
TEAMSPEAK_VERSION="3.0.13.8"
TEAMSPEAK_INSTALLDIR="/opt"

#USER
adduser --disabled-password --gecos "" teamspeak

#SERVICE
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

chmod 664 /etc/systemd/system/teamspeak3server.service
sudo systemctl daemon-reload
sudo systemctl enable teamspeak3server.service

#SUDO
cat << EOF > 
# Cmnd alias specification
Cmnd_Alias TEAMSPEAK_CMDS = /bin/systemctl start teamspeak3server, /bin/systemctl stop teamspeak3server, /bin/systemctl restart teamspeak3server, /bin/systemctl status teamspeak3server

# User privilege specification
teamspeak ALL=NOPASSWD: TEAMSPEAK_CMDS
EOF

#INSTALL
wget http://dl.4players.de/ts/releases/$TEAMSPEAK_VERSION/teamspeak3-server_linux_amd64-$TEAMSPEAK_VERSION.tar.bz2 --directory-prefix=$TEAMSPEAK_INSTALLDIR
mkdir $TEAMSPEAK_INSTALLDIR/teamspeak-server-$TEAMSPEAK_VERSION
tar xfv $TEAMSPEAK_INSTALLDIR/teamspeak3-server_linux_amd64-$TEAMSPEAK_VERSION.tar.bz2 -C $TEAMSPEAK_INSTALLDIR/teamspeak-server-$TEAMSPEAK_VERSION --strip 1
ln -s $TEAMSPEAK_INSTALLDIR/teamspeak-server-$TEAMSPEAK_VERSION $TEAMSPEAK_INSTALLDIR/teamspeak-server
chown -R teamspeak:teamspeak $TEAMSPEAK_INSTALLDIR/teamspeak-server-$TEAMSPEAK_VERSION
chmod 0770 $TEAMSPEAK_INSTALLDIR/teamspeak-server-$TEAMSPEAK_VERSION

#CLEANUP
rm $TEAMSPEAK_INSTALLDIR/teamspeak3-server_linux_amd64-$TEAMSPEAK_VERSION.tar.bz2

#MANUAL
#this generates your access masterkey
/opt/teamspeak-server/ts3server_startscript.sh start
