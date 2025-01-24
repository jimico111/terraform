#!/bin/bash
yum -y install httpd mod_ssl
echo "myWEB" > /var/www/html/index.html
systemctl enable --now httpd.service