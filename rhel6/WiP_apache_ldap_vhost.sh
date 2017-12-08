#!/bin/bash
#APACHE LDAP CONFIGURATION
#Reverse-Proxy with LDAP authetification
#Matthias van Gemmern
#2017-12-08

. apache_ldap_vhost.conf

cat << EOF > /etc/httpd/sites-available/$URL.vhost
<VirtualHost $URL:443>
        ServerName $URL.com
        ServerAdmin admin@mysite.com

  SSLEngine on
  SSLCertificateFile /etc/httpd/ssl/$URL.crt
  SSLCertificateKeyFile /etc/httpd/ssl/$URL.key

  #
  # Proxy
  #
ProxyRequests Off
<Proxy *>
    Order Allow,Deny
    Allow from all
    AuthName "$LOGINPROMPT"
    AuthBasicProvider ldap
    AuthType Basic
    AuthzLDAPAuthoritative off
    AuthLDAPURL "ldap://$DC1$DC2:389/OU=$OULDAP,DC=$DC1,DC=$DC2?sAMAccountName?sub?(objectClass=user)"
    AuthLDAPBindDN "CN=$CN1,OU=$OU1,OU=$OULDAP,DC=$DC1,DC=$DC2"
    AuthLDAPBindPassword "$LDAPPW"
    #require valid-user
    require ldap-group CN=$GROUP,OU=$OUGROUPS,OU=$OULDAP,DC=$DC1,DC=$DC2
</Proxy>
  ProxyPass / http://127.0.0.1:$REVERSEPROXYPORT
  ProxyPassReverse / http://127.0.0.1:$REVERSEPROXYPORT
  RewriteEngine on
  RewriteCond %{DOCUMENT_ROOT}/%{REQUEST_FILENAME} !-f
  RewriteRule .* http://127.0.0.1:$REVERSEPROXYPORT%{REQUEST_URI} [P,QSA]

        ErrorLog ${APACHE_LOG_DIR}/$URL_error.log
        LogLevel warn
        CustomLog ${APACHE_LOG_DIR}/$URL_access.log combined
</VirtualHost>
EOF
