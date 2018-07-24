#!/bin/bash
#TEAMSPEAK3-INSTALL
#Architecture x86-64
#requires: none
#Matthias van Gemmern
#2018-07-24


#VARS
TEAMSPEAK_VERSION="3.2.0"
TEAMSPEAK_INSTALLDIR="/opt"
TEAMSPEAK_FRESHINSTALL="YES"


#USER
adduser --disabled-password --gecos "" teamspeak


#SERVICE
systemctl stop teamspeak3server
#workaround when stop is not working
pkill ts3server
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
cat << EOF > /etc/sudoers.d/teamspeak
# Cmnd alias specification
Cmnd_Alias TEAMSPEAK_CMDS = /bin/systemctl start teamspeak3server, /bin/systemctl stop teamspeak3server, /bin/systemctl restart teamspeak3server, /bin/systemctl status teamspeak3server

# User privilege specification
teamspeak ALL=NOPASSWD: TEAMSPEAK_CMDS
EOF
chmod 0440 /etc/sudoers.d/teamspeak
#TODOecho "includedir /etc/sudoers.d" >> /etc/sudoers


#INSTALL
wget http://dl.4players.de/ts/releases/$TEAMSPEAK_VERSION/teamspeak3-server_linux_amd64-$TEAMSPEAK_VERSION.tar.bz2 --directory-prefix=$TEAMSPEAK_INSTALLDIR
if [ ! -d $TEAMSPEAK_INSTALLDIR/teamspeak-server-$TEAMSPEAK_VERSION/ ]; then
    mkdir $TEAMSPEAK_INSTALLDIR/teamspeak-server-$TEAMSPEAK_VERSION
    if [ ! "$TEAMSPEAK_FRESHINSTALL" == "YES" ]; then
        cp -a $TEAMSPEAK_INSTALLDIR/teamspeak-server $TEAMSPEAK_INSTALLDIR/teamspeak-server-$TEAMSPEAK_VERSION
    fi
    touch $TEAMSPEAK_INSTALLDIR/teamspeak-server/lastused-"´date´"
    tar xfv $TEAMSPEAK_INSTALLDIR/teamspeak3-server_linux_amd64-$TEAMSPEAK_VERSION.tar.bz2 -C $TEAMSPEAK_INSTALLDIR/teamspeak-server-$TEAMSPEAK_VERSION --strip 1
    ln -snf $TEAMSPEAK_INSTALLDIR/teamspeak-server-$TEAMSPEAK_VERSION $TEAMSPEAK_INSTALLDIR/teamspeak-server
    chown -R teamspeak:teamspeak $TEAMSPEAK_INSTALLDIR/teamspeak-server-$TEAMSPEAK_VERSION
    chmod 0770 $TEAMSPEAK_INSTALLDIR/teamspeak-server-$TEAMSPEAK_VERSION
else
    echo "This version already exists, exiting..."
fi

#CLEANUP
rm $TEAMSPEAK_INSTALLDIR/teamspeak3-server_linux_amd64-$TEAMSPEAK_VERSION.tar.bz2

#SERVICE
if [ ! "$TEAMSPEAK_FRESHINSTALL" == "YES" ]; then
    systemctl start teamspeak3server
fi

#MANUAL
#this generates your access masterkey (only on fresh installed version)
/opt/teamspeak-server/ts3server_startscript.sh start
