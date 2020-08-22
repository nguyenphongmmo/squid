#!/bin/bash
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -p tcp --dport 22 -j ACCEPT
iptables -I INPUT -p tcp --dport 3128 -j ACCEPT
iptables -I INPUT -p tcp --dport 3129 -j ACCEPT
sudo iptables -t nat -A PREROUTING -i ens4 -p tcp --dport 80 -j REDIRECT --to-port 3128
sudo iptables -t nat -A PREROUTING -i ens4 -p tcp --dport 443 -j REDIRECT --to-port 3129