sudo apt-get install -y openhab2-addons openhab2 openjdk-8-jdk apache2-utils

nano /etc/nginx/sites-enabled/openhab.vhost
--->
server {
        listen                          80;
        server_name                     $SERVER_NAME;

        location / {
                proxy_pass                            http://localhost:8080;
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
 sudo htpasswd -c /etc/nginx/.htpasswd $ACCOUNTNAME


systemctl restart nginx
systemctl enable openhab2
systemctl start openhab2
