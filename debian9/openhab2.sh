sudo apt-get install -y openhab2-addons openhab2 openjdk-8-jdk apache2-utils

nano /etc/nginx/sites-available/openhab.vhost
--->
server {
    if ($host = $URL) {
        return 301 https://$host$request_uri;
    }

    listen 80;
    listen [::]:80;
    server_name $URL;
}
server {
    listen 443;
    listen [::]:443;
    server_name $URL;

    ssl on;
    ssl_protocols TLSv1.2;#TLSv1.3 requires nginx >= 1.13.0
    ssl_certificate /etc/letsencrypt/live/$URL/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/$URL/privkey.pem; # managed by Certbot
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_prefer_server_ciphers on;
    ssl_ciphers AES256+EECDH:AES256+EDH:!aNULL;
    ssl_ecdh_curve secp384r1;

    location / {
        proxy_pass                            http://$REVERSEIP:8080;
        proxy_buffering                       off;
        proxy_set_header Host                 $http_host;
        proxy_set_header X-Real-IP            $remote_addr;
        proxy_set_header X-Forwarded-For      $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto    $scheme;
        auth_basic                            "Username and Password Required";
        auth_basic_user_file                  /etc/nginx/.htpasswd;
    }
}
<---
ln -s /etc/nginx/sites-available/openhab.vhost /etc/nginx/sites-enabled/openhab.vhost
 sudo htpasswd -c /etc/nginx/.htpasswd $ACCOUNTNAME


systemctl restart nginx
systemctl enable openhab2
systemctl start openhab2
