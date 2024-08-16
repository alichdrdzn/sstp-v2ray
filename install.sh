#!/bin/bash
apt update && apt install tcpdump htop build-essential netfilter-persistent speedtest-cli snapd dnsutils haproxy -y
wget http://www.softether-download.com/files/softether/v4.42-9798-rtm-2023.06.30-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-v4.42-9798-rtm-2023.06.30-linux-x64-64bit.tar.gz
wget https://github.com/alichdrdzn/soft-down/blob/main/vpn_server.config
tar xvf softether-vpnserver-v4.42-9798-rtm-2023.06.30-linux-x64-64bit.tar.gz
cd vpnserver
make
cp /root/vpn_server.config /root/vpnserver/
chmod 600 * && chmod 700 vpnserver && chmod 700 vpncmd
wget https://raw.githubusercontent.com/alichdrdzn/soft-down/main/install.sh
cat haproxy.cfg /etc/haproxy/haproxy.cfd
systemctl disable haproxy && systemctl stop haproxy
./vpnserver start
sleep 2
netstat -ntpl
echo "@reboot /root/vpnserver/vpnserver start" >> /var/spool/cron/crontabs/root
echo "Port 17971" >> /etc/ssh/sshd_config
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -s localhost -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -p tcp -m tcp --sport 53 -j ACCEPT
iptables -A INPUT -p tcp -m udp --sport 53 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 17971 -j ACCEPT
iptables -P INPUT DROP
service netfilter-persistent save
netfilter-persistent save
systemctl restart sshd
echo -e "\ndone."
