#BASIC RPI CONFIGURATION DEBIAN9
#Matthias van Gemmern
#2018-05-23


#include config
. basic_system.conf

#Install packages and patches
apt-get update
apt-get upgrade -y
apt-get install -y tor

#Modify default pi user
usermod -p $PASSWORDHASH_PI pi
usermod -s /bin/false pi

#Modify root
usermod -p $PASSWORDHASH_ROOT root

#Add new user
#generate password with: perl -e 'print crypt("THEPASSWORD", "salt"),"\n"'
useradd -m -p $PASSWORDHASH_USER1 -s /bin/bash -u $USER1_USERID $USER1_USERNAME
sudo -u $USER1_USERNAME ssh-keygen -t rsa -b 2048 -f /home/$USER1_USERNAME/.ssh/id_rsa -C "notes" -N ''
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


#MODIFY CONFIG
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

#MANAGE SERVICES
systemctl restart ssh
systemctl restart tor
systemctl enable ssh
systemctl enable tor
systemctl stop bluetooth
systemctl disable bluetooth
