#!/bin/bash
#OPENVPN-CLIENT
#requires: none
#Matthias van Gemmern
#2018-07-24


#INSTALL
sudo apt-get update && sudo apt-get install openvpn -y
##TODO---->cp /home/$USER/client.ovpn /etc/openvpn/client.conf

#SERVICE
sudo systemctl enable openvpn
sudo systemctl start openvpn
