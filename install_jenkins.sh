#!/bin/bash

DNSNAME="kingwai-sit"

# Update and install some tools
sudo yum -y update
sudo yum -y install git wget

# Enable IPv4 Forwarding
sudo sed '/net.ipv4.ip_forward/d' /etc/sysctl.conf > /etc/sysctl.conf.tmp
sudo mv -f /etc/sysctl.conf.tmp /etc/sysctl.conf
sudo echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

# Install Apache Proxy
sudo yum -y install httpd
sudo systemctl enable httpd

# Install SSL
sudo yum -y install mod_ssl
sudo mkdir -p /etc/ssl/private
sudo chmod 700 /etc/ssl/private
sudo openssl req -new -newkey rsa:4096 -days 36500 -nodes -x509 -subj "/C=VN/ST=HCM/L=HCM/O=DXC/OU=BnD/CN=$DNSNAME" -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt

# Change httpd configuration
cat <<EOL > /etc/httpd/conf.d/vhosts.conf
<VirtualHost *:80>
ServerName $DNSNAME
Timeout 60

RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule (.*) https://%{SERVER_NAME}\$1 [R,L]

</VirtualHost>
EOL

cat <<EOL > /etc/httpd/conf.d/ssl.conf
Listen 443 https

SSLPassPhraseDialog exec:/usr/libexec/httpd-ssl-pass-dialog

SSLSessionCache         shmcb:/run/httpd/sslcache(512000)
SSLSessionCacheTimeout  300


SSLRandomSeed startup file:/dev/urandom  256
SSLRandomSeed connect builtin
#SSLRandomSeed startup file:/dev/random  512
#SSLRandomSeed connect file:/dev/random  512
#SSLRandomSeed connect file:/dev/urandom 512

SSLCryptoDevice builtin
#SSLCryptoDevice ubsec

##
## SSL Virtual Host Context
##

<VirtualHost _default_:443>

ServerName $DNSNAME:443
ProxyTimeout 1200
Timeout 1200

ErrorLog logs/ssl_error_log
TransferLog logs/ssl_access_log
LogLevel warn

SSLEngine on
SSLProtocol all -SSLv2 -SSLv3
SSLCipherSuite HIGH:3DES:!aNULL:!MD5:!SEED:!IDEA

SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
#SSLCertificateChainFile /etc/pki/tls/certs/server-chain.crt
#SSLCACertificateFile /etc/pki/tls/certs/ca-bundle.crt

<Files ~ "\.(cgi|shtml|phtml|php3?)$">
    SSLOptions +StdEnvVars
</Files>
<Directory "/var/www/cgi-bin">
    SSLOptions +StdEnvVars
</Directory>

BrowserMatch "MSIE [2-5]" \
         nokeepalive ssl-unclean-shutdown \
         downgrade-1.0 force-response-1.0

CustomLog logs/ssl_request_log \
          "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"

ProxyPreserveHost On
ProxyRequests off

AllowEncodedSlashes NoDecode
RequestHeader set X-Forwarded-Proto "https"
RequestHeader set X-Forwarded-Port "443"

SetEnv force-proxy-request-1.0 1
SetEnv proxy-nokeepalive 1

SetOutputFilter DEFLATE
SetEnvIfNoCase Request_URI "\.(?:gif|jpe?g|png)$" no-gzip

RewriteEngine On
RewriteCond %{HTTP:UPGRADE} ^WebSocket$ [NC]
RewriteCond %{HTTP:CONNECTION} Upgrade$ [NC]
RewriteRule .* ws://$IPADDR:2012%{REQUEST_URI} [P]

ProxyPass "/jenkins"  "http://$IPADDR:8080/jenkins" nocanon
ProxyPassReverse "/jenkins" "http://$IPADDR:8080/jenkins"
ProxyPassReverse "/jenkins" "http://$DNSNAME/jenkins"

</VirtualHost>
EOL


# Add allow ports on firewall
#sudo yum install -y firewalld
#sudo firewall-cmd --permanent --zone=public --add-port=80/tcp # http
#sudo firewall-cmd --permanent --zone=public --add-port=443/tcp # https
#sudo firewall-cmd --reload

#  Allow apache to make network connections
sudo setsebool -P httpd_can_network_connect 1

# Restart Apache Proxy
sudo systemctl restart httpd

# Install Jenkins
sudo yum -y install java-1.8.0-openjdk-devel
yum -y install epel-release
curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo yum -y install jenkins
sudo systemctl enable jenkins

# Change user jenkins to root
sudo sed -i 's/JENKINS_USER=\"jenkins\"/JENKINS_USER=\"root\"/g' /etc/sysconfig/jenkins

# Config prefix for jenkins
sudo sed -i 's/JENKINS_ARGS=\"\"/JENKINS_ARGS=\"--prefix=\/jenkins\"/g' /etc/sysconfig/jenkins

sudo systemctl start jenkins 

sudo sleep 5

sudo echo $(cat /var/lib/jenkins/secrets/initialAdminPassword) > /var/www/html/index.html