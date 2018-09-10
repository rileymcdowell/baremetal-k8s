#!/bin/bash

which nginx &> /dev/null
if [ "$?" != "0" ] ; then
    sudo apt install -y nginx
fi

sudo tee /etc/nginx/nginx.conf > /dev/null <<EOF
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
        # multi_accept on;
}

http {

        ##
        # Basic Settings
        ##

        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        # server_tokens off;

        # server_names_hash_bucket_size 64;
        # server_name_in_redirect off;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ##
        # SSL Settings
        ##

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        ##
        # Logging Settings
        ##

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        ##
        # Gzip Settings
        ##

        gzip on;

        # gzip_vary on;
        # gzip_proxied any;
        # gzip_comp_level 6;
        # gzip_buffers 16 8k;
        # gzip_http_version 1.1;
        # gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

        ##
        # Virtual Host Configs
        ##

	# Not for nginx as a proxy
        #include /etc/nginx/sites-enabled/*;
}

include /etc/nginx/conf.d/*.conf;
EOF

sudo tee /etc/nginx/conf.d/ingress-proxy.conf > /dev/null <<EOF
stream {
  upstream backend_80 {
    server 10.96.96.96:80;
  }
upstream backend_443 {
    server 10.96.96.96:443;
  }
upstream backend_8080 {
    server 10.96.96.96:8080;
  }
upstream backend_8443 {
    server 10.96.96.96:8443;
  }
upstream backend_8843 {
    server 10.96.96.96:8843;
  }
upstream backend_8880 {
    server 10.96.96.96:8880;
  }
upstream backend_3478 {
    server 10.96.96.96:3478;
  }
upstream backend_6789 {
    server 10.96.96.96:6789;
  }
upstream backend_10001 {
    server 10.96.96.96:10001;
  }

server {
    listen 80; proxy_pass backend_80;
  }
server {
    listen 443; proxy_pass backend_443;
  }
server { 
    listen 8080; proxy_pass backend_8080;
  }
server { 
    listen 8443; proxy_pass backend_8443;
  }
server { 
    listen 8843; proxy_pass backend_8843;
  }
server { 
    listen 8880; proxy_pass backend_8880;
  }
server { 
    listen 3478 udp; proxy_pass backend_3478;
  }
server { 
    listen 6789; proxy_pass backend_6789;
  }
server { 
    listen 10001 udp; proxy_pass backend_10001;
  }
}
EOF

sudo systemctl reload nginx.service

echo "Done"
