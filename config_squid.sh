#!/bin/bash
#/etc/squid/ is folder binary squid
cd /etc/squid/
mkdir -p /etc/squid/ssl
chmod -R 700 ssl
cd ssl
openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -extensions v3_ca -keyout phong.pem -out phong.pem<< EOF
AU
New South Wales
Newcastle
phong
phong
phong
pop.npc@gmail.com
EOF
chmod 744 phong.pem
openssl x509 -in phong.pem -outform DER -out phong.der
/usr/lib/squid/security_file_certgen -c -s /var/lib/ssl_db -M 4MB
chown -R proxy:proxy /var/lib/ssl_db
cp /etc/squid/squid.conf /etc/squid/squid.conf.org
rm -rf /etc/squid/squid.conf
touch /etc/squid/squid.conf
cat > "/etc/squid/squid.conf" <<END
#acl localnet src 0.0.0.1–0.255.255.255 # RFC 1122 "this" network (LAN)
acl localnet src 10.0.0.0/8 # RFC 1918 local private network (LAN)
acl localnet src 100.64.0.0/10 # RFC 6598 shared address space (CGN)
acl localnet src 169.254.0.0/16 # RFC 3927 link-local (directly plugged) machines
acl localnet src 172.16.0.0/12 # RFC 1918 local private network (LAN)
acl localnet src 192.168.0.0/16 # RFC 1918 local private network (LAN)
acl localnet src fc00::/7 # RFC 4193 local private network range
acl localnet src fe80::/10 # RFC 4291 link-local (directly plugged) machines
#acl private src 10.14.0.2/32 # from private instance
acl SSL_ports port 443 563 1863 5190 5222 5050 6667
acl Safe_ports port 80 # http
acl Safe_ports port 21 # ftp
acl Safe_ports port 443 # https
acl Safe_ports port 70 # gopher
acl Safe_ports port 210 # wais
#acl Safe_ports port 1025–65535 # unregistered ports
acl Safe_ports port 280 # http-mgmt
acl Safe_ports port 488 # gss-http
acl Safe_ports port 591 # filemaker
acl Safe_ports port 777 # multiling http
acl CONNECT method CONNECT
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
coredump_dir /var/spool/squid
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320
http_access allow localhost
http_access allow localnet
#ssl_bump allow all
visible_hostname squid
cache deny all
# Log format and rotation
logformat squid %ts.%03tu %6tr %>a %Ss/%03>Hs %<st %rm %ru %ssl::>sni %Sh/%<a %mt
logfile_rotate 10
debug_options rotate=10
# Handling HTTP requests
http_port 3127
http_port 3128 intercept
acl allowed_http_sites dstdomain "/etc/squid/whitelist.txt"
http_access allow allowed_http_sites
# Handling HTTPS requests
https_port 3129 intercept ssl-bump cert=/etc/squid/ssl/phong.pem generate-host-certificates=on dynamic_cert_mem_cache_size=4MB
acl SSL_port port 443
http_access allow SSL_port
#acl allowed_https_sites ssl::server_name "/etc/squid/whitelist.conf"
acl allowed_https_sites ssl::server_name .google.com .googleapis.com
sslcrtd_program /usr/lib/squid/security_file_certgen -s /var/lib/ssl_db -M 4MB
#acl step1 at_step SslBump1
#ssl_bump peek step1
acl step1 at_step SslBump1
acl step2 at_step SslBump2
acl step3 at_step SslBump3
ssl_bump peek step1 all
ssl_bump peek step2 allowed_https_sites
ssl_bump splice step3 allowed_https_sites
ssl_bump terminate step2 all
#ssl_bump client-first allowed_https_sites
ssl_bump none all
# only wait 5 seconds to terminate active connections
#shutdown_lifetime 5
http_access deny all
debug_options ALL,2 28,9
#ssl_bump splice all
END
touch /etc/squid/whitelist.txt
cat > "/etc/squid/whitelist.txt" <<END

END

#test error squid
squid -k parse
service squid restart
