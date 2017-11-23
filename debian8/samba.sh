#SAMBA CONFIGURATION
#tested in debian8
#Matthias van Gemmern
#2017-11-06


. samba.conf


apt-get update
apt-get install -y samba

if [ -f /etc/samba/smb.conf.orig ]
then
	  echo "Original config already copied"
else
	  cp /etc/samba/smb.conf /etc/samba/smb.conf.orig
fi
cat /etc/samba/smb.conf.orig|grep -v "^#"|grep -v "^;"|awk 'NF'| sed '/\[Main\]/Q' > /etc/samba/smb.conf

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

useradd $USER --system --no-create-home -s /bin/false
usermod -L $USER
(echo "$PASSWORD"; echo "$PASSWORD") | smbpasswd -s


sudo systemctl enable smbd
sudo systemctl start smbd
