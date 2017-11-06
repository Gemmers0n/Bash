apt-get install tor -y
echo "HiddenServiceDir /var/lib/tor/hidden_service/" > /etc/tor/torrc
echo "HiddenServicePort 1337 `ip a s eth0 | awk '/inet / {print$2}' | cut -d/ -f1`:1337" >> /etc/tor/torrc
mkdir /var/lib/tor/hidden_service
chown debian-tor:debian-tor /var/lib/tor/hidden_service
chmod 0700 /var/lib/tor/hidden_service
systemctl restart tor
systemctl enable tor
cat /var/lib/tor/hidden_service/hostname
