#!/bin/bash
#SYSTEM CONFIGURATION
#requires: none
#Matthias van Gemmern
#2018-07-24


#INCLUDE
. system.conf

#INSTALL
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y tor

#CONFIG
#Modify default pi user
usermod -p $PASSWORDHASH_PI pi
usermod -s /bin/false pi

#Modify root
usermod -p $PASSWORDHASH_ROOT root

#Generate System Key
ssh-keygen -t ecdsa -b 521 -N ''

#Add new user
#generate password with: perl -e 'print crypt("THEPASSWORD", "salt"),"\n"'
useradd -m -p $PASSWORDHASH_USER1 -s /bin/bash -u $USER1_USERID $USER1_USERNAME
sudo -u $USER1_USERNAME ssh-keygen -t ecdsa -b 521 -f /home/$USER1_USERNAME/.ssh/id_rsa -N ''
#Echo your Existing key for Login to System
echo $USER1_PUBKEY >> /home/$USER1_USERNAME/.ssh/authorized_keys


#copy original config
BACKUP_CONFIGS="/etc/sudoers /etc/ssh/sshd_config /etc/tor/torrc"
for SRC in $BACKUP_CONFIGS
do
    if [ ! -f $SRC.orig ]
    then
        cp $SRC $SRC.orig
    fi
done

##modify ssh
cat /etc/ssh/sshd_config.orig |grep -v "^#" |grep -v PermitRootLogin|grep -v 22|grep -v PubkeyAuthentication| grep -v PasswordAuthentication|grep -v UsePAM| awk 'NF' > /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "UsePAM no" >> /etc/ssh/sshd_config
echo "Port "$SSH_PORT >> /etc/ssh/sshd_config

##modify sudoers
cat /etc/sudoers.orig|grep -v "pi ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers

##modify tor
mkdir /var/lib/tor/hidden_service
chown debian-tor:debian-tor /var/lib/tor/hidden_service
chmod 0700 /var/lib/tor/hidden_service
echo "HiddenServiceDir /var/lib/tor/hidden_service/" > /etc/tor/torrc
echo "HiddenServicePort $SSH_PORT 127.0.0.1:$SSH_PORT" >> /etc/tor/torrc

#SERVICES
systemctl restart ssh
systemctl restart tor
systemctl enable ssh
systemctl enable tor
systemctl stop bluetooth
systemctl disable bluetooth
