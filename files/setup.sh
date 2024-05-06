#!/bin/bash

sudo apt update
sudo apt install nginx fail2ban -y

sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

sudo systemctl enable nginx
sudo systemctl restart nginx

sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Filtro p/ nginx

sudo tee /etc/fail2ban/filter.d/nginx.conf <<EOF
[Definition]
failregex = ^<HOST>.*"(GET|POST).*" (400|401|403|404|444|500) .*$
ignoreregex =
EOF

# jail

sudo tee -a /etc/fail2ban/jail.local <<EOF
[nginx]
enabled = true
port = http,https
filter = nginx
logpath = /var/log/nginx*/*access.log
action = iptables-multiport[name=404, port="http,https", protocol=tcp]
maxretry = 5
findtime = 30
bantime = 7200
EOF

sudo systemctl restart fail2ban