# system.network_conf.sh
cat << EOF > /etc/sysctl.d/network.conf
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.nf_conntrack_max = 512000
net.ipv4.tcp_keepalive_intvl = 60 
net.ipv4.tcp_keepalive_probes = 10 
net.ipv4.tcp_keepalive_time = 600
net.netfilter.nf_conntrack_tcp_timeout_established = 1800
net.ipv4.conf.all.route_localnet = 1
EOF
echo 128000 > /sys/module/nf_conntrack/parameters/hashsize
sysctl --system
iptables -t nat -A PREROUTING -p tcp -d 169.254.170.2 --dport 80 -j DNAT --to-destination 127.0.0.1:51679
iptables -t nat -A OUTPUT -d 169.254.170.2 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 51679
