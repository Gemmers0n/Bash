. system_debain8.conf

#BASIC RPI CONFIGURATION
#Matthias van Gemmern
#2017-11-06


#Modify default pi account
usermod -p $PASSWORDHASH_PI pi
usermod -s /bin/false pi

#Modify root
usermod -p $PASSWORDHASH_ROOT root

#Add new Login User
#Passwort generieren mit: perl -e 'print crypt("DASPASSWORT", "salt"),"\n"'
useradd -m -p $PASSWORDHASH_USER1 -u $USER1_USERID $USER1_USERNAME
sudo -u `$USER1_USERNAME` ssh-keygen -t rsa -b 2048 -f /home/`$USER1_USERNAME`/.ssh/id_rsa -C "notes" -N ''
echo $USER1_PUBKEY >> /home/`$USER1_USERNAME`/.ssh/authorized_keys

#Set host-based config with MAC-Address
if [ `ip addr | grep link/ether | awk '{print $2}'` == $HOST1_MAC ]; then
    echo "HOSTNAME="$HOST1_HOSTNAME >> /etc/environment
    echo "UUID="$HOST1_DISK"       /external       ext4    defaults,nofail      0       0" >> /etc/fstab
    #Add group for external drive
    groupadd --gid $DISK_GROUPID $DISK_GROUPNAME
    usermod -G $DISK_GROUPNAME $USER1_USERNAME
else
    echo "Error: no configured MAC-Address"
fi

#Install patches and packages
apt-get update
apt-get upgrade -y
apt-get install fail2ban -y
systemctl enable fail2ban


#Modify ssh config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.org
cat /etc/ssh/sshd_config.org |grep -v "^#" |grep -v PermitRootLogin|grep -v 22|grep -v PubkeyAuthentication| grep -v PasswordAuthentication|grep -v UsePAM| awk 'NF' > /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "UsePAM no" >> /etc/ssh/sshd_config
echo "Port "$SSH_PORT >> /etc/ssh/sshd_config
systemctl enable sshd
systemctl restart sshd


#Remove pi from sudoers
cp /etc/sudoers /etc/sudoers.org
cat /etc/sudoers.org|grep -v "pi ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers


####todo into crontab.d file
echo "####PATCH####" >> /var/spool/cron/crontabs/root

echo "30 2 * * * curl http://www.wieistmeineip.de/|grep '<div class="title"><strong>'|sed s/'>'/:/g|sed s/'<'/:/g|cut -d ":" -f5|head -n1 > /external/Documents/RaspberryPI/IP_"$HOSTNAME".txt" >> /var/spool/cron/crontabs/root
####

init 6
