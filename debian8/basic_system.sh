#BASIC RPI CONFIGURATION
#Matthias van Gemmern
#2017-12-27


#include config
. basic_system.conf

#Install packages and patches
apt-get update
apt-get upgrade -y
apt-get remove -y nano
apt-get install -y fail2ban vim apt-file 
apt-file update

#Modify default pi account
usermod -p $PASSWORDHASH_PI pi
usermod -s /bin/false pi

#Modify root
usermod -p $PASSWORDHASH_ROOT root

#Add new Login User
#Passwort generieren mit: perl -e 'print crypt("DASPASSWORT", "salt"),"\n"'
useradd -m -p $PASSWORDHASH_USER1 -s /bin/bash -u $USER1_USERID $USER1_USERNAME
sudo -u $USER1_USERNAME ssh-keygen -t rsa -b 2048 -f /home/$USER1_USERNAME/.ssh/id_rsa -C "notes" -N ''
echo $USER1_PUBKEY >> /home/$USER1_USERNAME/.ssh/authorized_keys

#Set host-based config with MAC-Address
if [ `ip addr | grep link/ether | head -n 1 | awk '{print $2}'` == $HOST1_MAC ]; then
    echo "HOSTNAME="$HOST1_HOSTNAME >> /etc/environment
    echo $HOST1_HOSTNAME > /etc/hostname
    echo "UUID="$HOST1_DISK"       /external       ext4    defaults,nofail      0       0" >> /etc/fstab
    #Add group for external drive
    groupadd --gid $DISK_GROUPID $DISK_GROUPNAME
    usermod -G $DISK_GROUPNAME $USER1_USERNAME
else
    echo "Error: no configured MAC-Address"
fi
if [ `ip addr | grep link/ether | head -n 1 | awk '{print $2}'` == $HOST2_MAC ]; then
    echo "HOSTNAME="$HOST2_HOSTNAME >> /etc/environment
    echo $HOST2_HOSTNAME > /etc/hostname
    #echo "UUID="$HOST1_DISK"       /external       ext4    defaults,nofail      0       0" >> /etc/fstab
    #Add group for external drive
    #groupadd --gid $DISK_GROUPID $DISK_GROUPNAME
    #usermod -G $DISK_GROUPNAME $USER1_USERNAME
else
    echo "Error: no configured MAC-Address"
fi

#copy original config
if [ -f /etc/ssh/sshd_config.orig ]
then
	  echo "Original config already copied"
else
	  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
fi

if [ -f /etc/sudoers.orig ]
then
	  echo "Original config already copied"
else
	  cp /etc/sudoers /etc/sudoers.orig
fi

#modify config
##modify ssh
cat /etc/ssh/sshd_config.orig |grep -v "^#" |grep -v PermitRootLogin|grep -v 22|grep -v PubkeyAuthentication| grep -v PasswordAuthentication|grep -v UsePAM| awk 'NF' > /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "UsePAM no" >> /etc/ssh/sshd_config
echo "Port "$SSH_PORT >> /etc/ssh/sshd_config

##modify sudoers
cat /etc/sudoers.orig|grep -v "pi ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers

##modify crontab
#TODO into crontab.d file
echo "####PATCH####" >> /var/spool/cron/crontabs/root
echo "30 2 * * * curl http://www.wieistmeineip.de/|grep '<div class="title"><strong>'|sed s/'>'/:/g|sed s/'<'/:/g|cut -d ":" -f5|head -n1 > /external/Documents/RaspberryPI/IP_"$HOSTNAME".txt" >> /var/spool/cron/crontabs/root

#restart and enable service autostart
#TODO ssh instead sshd debian9
systemctl restart sshd
systemctl restart fail2ban
systemctl enable sshd
systemctl enable fail2ban
