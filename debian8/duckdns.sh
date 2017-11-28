include ./duckdns.conf
mkdir /opt/duckdns
cd /opt/duckdns
echo 'echo url="https://www.duckdns.org/update?domains=$URL&token=$TOKEN&ip=" | curl -k -o /opt/duckdns/duck.log -K -' > duck.sh
chmod 700 duck.sh
./duck.sh


#TODO in cron file
echo "*/5 * * * * /opt/duckdns/duck.sh >/dev/null 2>&1" >> /var/spool/cron/crontabs/root
