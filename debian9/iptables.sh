#!/bin/bash
#NGINX CONFIGURATION
#requires: none
#Matthias van Gemmern
#2018-07-24


#INSTALL
sudo apt-get update && sudo apt-get install -y iptables-persistent

#CONFIG
cat iptables.conf > /etc/network/iptables
sudo iptables-apply /etc/network/iptables
sudo iptables-save
