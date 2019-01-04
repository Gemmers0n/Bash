#SAMBA CONFIGURATION
#tested in debian8
#Matthias van Gemmern
#2017-11-23


#include config
. samba.conf

#install packages
apt-get update
apt-get install -y samba

#copy original config
if [ -f /etc/samba/smb.conf.orig ]
then
	  echo "Original config already copied"
else
	  cp /etc/samba/smb.conf /etc/samba/smb.conf.orig
fi

#generate structure
useradd $USER --system --no-create-home -s /bin/false
usermod -L $USER
smbpasswd -L -a $USER
smbpasswd -L -e $USER
(echo "$PASSWORD"; echo "$PASSWORD") | smbpasswd -s
#smbpasswd -a #rhel

#modify config
cat /etc/samba/smb.conf.orig|grep -v "^#"|grep -v "^;"|awk 'NF'| sed '/\[Main\]/Q' > /etc/samba/smb.conf
#TODO not smbd.conf
echo "unix charset = UTF-8" >> /etc/samba/smbd.conf
echo "dos charset = cp1252" >> /etc/samba/smbd.conf
echo "mangled names = no" >> /etc/samba/smbd.conf
echo "#Windows 7 Protocol Version" >> /etc/samba/smbd.conf
echo "server min protocol = SMB2_10" >> /etc/samba/smbd.conf
echo "#Windows 8 Protocol Version" >> /etc/samba/smbd.conf
echo "#server min protocol = SMB3_00" >> /etc/samba/smbd.conf
echo "#Windows 8.1 Protocol Version" >> /etc/samba/smbd.conf
echo "#server min protocol = SMB3_02" >> /etc/samba/smbd.conf
echo "[Main]" >> /etc/samba/smbd.conf
echo "path = /external" >> /etc/samba/smbd.conf
echo "writeable = yes" >> /etc/samba/smbd.conf
echo "write list = $USER" >> /etc/samba/smbd.conf
echo "valid users = $USER" >> /etc/samba/smbd.conf
echo "guest ok  = no" >> /etc/samba/smbd.conf

#restart and enable service autostart
sudo systemctl enable smbd
sudo systemctl start smbd
