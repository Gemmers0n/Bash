#TYPO3 CONFIGURATION
#Matthias van Gemmern
#2018-05-17

#######debian 8 only php 5.6 opnly typo 7.6.23 # 8.7.8 is php 7 # https://typo3.org/download/

. typo3.conf
#todo which packets are needed
mkdir -p /var/www/$URL1.duckdns.org/web
cd /var/www/$URL1.duckdns.org/
rm -f $VERSION
#doesnt load as tar.gz but is extractable
#wget --content-disposition https://get.typo3.org/9
wget https://get.typo3.org/$VERSION
#tar -xzvf typo3*
tar -xzvf $VERSION
#rm -f typo3*
rm -f $VERSION
cd /var/www/$URL1.duckdns.org/web/
ln -s ../typo3_src-$VERSION typo3_src
ln -s typo3_src/index.php
ln -s typo3_src/typo3
#maybe more rights
chown -R www-data:www-data /var/www/$URL1.duckdns.org/*

#TODO Mysql or Mariadb config still asks for pw
#debian9 mysql_secure_installation is needed
apt-get -y install mariadb-server mariadb-client


mysqladmin --defaults-file=/etc/mysql/debian.cnf create typo3
mysql --defaults-file=/etc/mysql/debian.cnf
##todo ab hier in mysql/mariadb
GRANT ALL PRIVILEGES ON typo3.* TO 'typo3_admin'@'localhost' IDENTIFIED BY 'typo3_admin_password';
GRANT ALL PRIVILEGES ON typo3.* TO 'typo3_admin'@'localhost.localdomain' IDENTIFIED BY 'typo3_admin_password';

FLUSH PRIVILEGES;

quit;
##todo bis hier mysql

systemctl restart mariadb
systemctl enable mariadb

#nginx defaults
sed -i '/location ~ /s/#//g' /etc/nginx/sites-available/default
sed -i '/include snippets\/fastcgi-php.conf/s/#//g' /etc/nginx/sites-available/default
#nano /etc/php5/fpm/pool.d/www.conf ### insert: listen = /var/run/php5-fpm.sock ###and remove 127.0.0.1:9000
#sed -i '/fastcgi_pass unix:\/var\/run\/php5-fpm.sock/s/#//g' /etc/nginx/sites-available/default
#sed -i 's/\(fastcgi_pass unix:\/var\/run\/php5-fpm.sock\;\).*/\1}/' /etc/nginx/sites-enabled/default
#TODO line above with 127.0.0.1:9000 #tcp connection instead of above socks
sed -i '/deny all/s/#//g' /etc/nginx/sites-available/default
sed -i 's/\(deny all\;\).*/\1}/' /etc/nginx/sites-available/default
#TODO doesnt work #sed -i 's/\(        index index.html index.htm index.nginx-debian.html\).*/\1" index.php"\;/' /etc/nginx/sites-available/default
#TODO ending }

##todo ssl config copy from server
cat << EOF > /etc/nginx/sites-available/$URL1.duckdns.org.vhost
server {
    listen 80;
    server_name 	$URL1.duckdns.org
	                192.168.178.27
	                raspberrypi
	                ;
    return 301 https://\$server_name\$request_uri;  # enforce https
}


server {
    listen 443;
    server_name 	$URL1.duckdns.org
	                192.168.178.27
	                raspberrypi
    root /var/www/$URL1.duckdns.org/web;
	
	ssl on;
	ssl_certificate ssl/$URL1.duckdns.org.chain.crt;
	ssl_certificate_key ssl/$URL1.duckdns.org.key;
	ssl_session_cache shared:SSL:10m;
	ssl_session_timeout 10m;	
	ssl_prefer_server_ciphers on;
	ssl_ciphers AES256+EECDH:AES256+EDH:!aNULL;
	ssl_dhparam /etc/nginx/dhparam.pem;
	
	add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";
	add_header X-Frame-Options DENY;
	add_header X-Content-Type-Options nosniff;
	

       if (\$http_host != "$URL1.duckdns.org") {
                 rewrite ^ https://$URL1.duckdns.org\$request_uri permanent;
       }

       index index.php index.html;

       location = /favicon.ico {
                log_not_found off;
                access_log off;
       }

       location = /robots.txt {
                allow all;
                log_not_found off;
                access_log off;
       }

       # Deny all attempts to access hidden files such as .htaccess, .htpasswd, .DS_Store (Mac).
       location ~ /\. {
                deny all;
                access_log off;
                log_not_found off;
       }


        location ~ \.php\$ {
                        try_files \$uri =404;
                        include /etc/nginx/fastcgi_params;
						#socket variant
                        #fastcgi_pass unix:/var/run/php5-fpm.sock;
						#tcp variant
						fastcgi_pass 127.0.0.1:9000;
                        fastcgi_index index.php;
                        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                        fastcgi_intercept_errors on;
                        fastcgi_buffer_size 128k;
                        fastcgi_buffers 256 16k;
                        fastcgi_busy_buffers_size 256k;
                        fastcgi_temp_file_write_size 256k;
                        fastcgi_read_timeout 1200;
        }
		
        client_max_body_size 100M;

        location ~ /\.(js|css)\$ {
                expires 604800s;
        }

        if (!-e \$request_filename){
                rewrite ^/(.+)\.(\d+)\.(php|js|css|png|jpg|gif|gzip)\$ /\$1.\$3 last;
        }

        location ~* ^/fileadmin/(.*/)?_recycler_/ {
                deny all;
        }
        location ~* ^/fileadmin/templates/.*(\.txt|\.ts)\$ {
                deny all;
        }
        location ~* ^/typo3conf/ext/[^/]+/Resources/Private/ {
                deny all;
        }
        location ~* ^/(typo3/|fileadmin/|typo3conf/|typo3temp/|uploads/|favicon\.ico) {
        }
        location ~* \.(eot|otf|ttf|woff|woff2)$ {
                add_header Access-Control-Allow-Origin *;
        }
        location / {
                        if (\$query_string ~ ".+") {
                                return 405;
                        }
                        if (\$http_cookie ~ 'nc_staticfilecache|be_typo_user|fe_typo_user' ) {
                                return 405;
                        } # pass POST requests to PHP
                        if (\$request_method !~ ^(GET|HEAD)$ ) {
                                return 405;
                        }
                        if (\$http_pragma = 'no-cache') {
                                return 405;
                        }
                        if (\$http_cache_control = 'no-cache') {
                                return 405;
                        }
                        error_page 405 = @nocache;

                        try_files /typo3temp/tx_ncstaticfilecache/\$host\${request_uri}index.html @nocache;
        }

        location @nocache {
                        try_files \$uri \$uri/ /index.php\$is_args\$args;
        }

}
EOF

cd /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/$URL1.duckdns.org.vhost $URL1.duckdns.org.vhost



###Debian8
apt-get -y install php5-fpm install php5-mysqlnd
#apt-get install -y php5-apcu #more speed with packages
#apt-get -y install php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-intl php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl #extra packages if needed
PHPHOME=/etc/php5



###Debian9
apt-get -y install php7.0-fpm php7.0-gd php7.0-xml php7.0-zip php7.0-mysql imagemagick
PHPHOME=/etc/php/7.0





###Debian8/9
cp $PHPHOME/fpm/php.ini $PHPHOME/fpm/php.ini.orig
cp $PHPHOME/fpm/pool.d/www.conf $PHPHOME/fpm/pool.d/www.conf.orig

#TODO uncomment and set session.cookie_secure = 1 and session.cookie_httponly = 1
sed -i 's/\(post_max_size = \).*/\120M/' $PHPHOME/fpm/php.ini
sed -i '/always_populate_raw_post_dat/s/^;//g' $PHPHOME/fpm/php.ini #not needed in php7 but doesnt hurt to be executed
sed -i 's/\(max_execution_time = \).*/\1240/' $PHPHOME/fpm/php.ini
sed -i 's/\(upload_max_filesize = \).*/\120M/' $PHPHOME/fpm/php.ini
sed -i '/max_input_vars/s/^;//g' $PHPHOME/fpm/php.ini
sed -i 's/\(max_input_vars = \).*/\12000/' $PHPHOME/fpm/php.ini
sed -i '/cgi.fix_pathinfo=/s/^;//g' $PHPHOME/fpm/php.ini
sed -i 's/\(cgi.fix_pathinfo=\).*/\10/' $PHPHOME/fpm/php.ini

#listen = 127.0.0.1:9000 # if no socks connection in $PHPHOME/fpm/pool.d/www.conf


###PHP-Test
mkdir /var/www/html
echo "<?php" > /var/www/html/info.php
echo "phpinfo();" >> /var/www/html/info.php
echo "?>" >> /var/www/html/info.php
chown -R www-data:www-data /var/www/html/
#rm -Rf /var/www/html # after use
###



#Debian9
systemctl restart php7.0-fpm
systemctl enable php7.0-fpm

#Debian8
systemctl restart php5-fpm
systemctl enable php5-fpm


systemctl restart nginx
systemctl enable nginx

touch /var/www/$URL1.duckdns.org/web/FIRST_INSTALL

#point browser to $DOMAIN/typo3
#TODO http instead of socket

#TODO edit mime types
#    application/font-woff2                woff2;

    # Browsers usually ignore the font media types and simply sniff
    # the bytes to figure out the font type.
    # https://mimesniff.spec.whatwg.org/#matching-a-font-type-pattern
    #
    # However, Blink and WebKit based browsers will show a warning
    # in the console if the following font types are served with any
    # other media types.

#application/x-font-ttf ttc ttf;

