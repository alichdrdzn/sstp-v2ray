#!/bin/bash
apt update && apt install tcpdump htop build-essential netfilter-persistent speedtest-cli -y
wget http://www.softether-download.com/files/softether/v4.42-9798-rtm-2023.06.30-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-v4.42-9798-rtm-2023.06.30-linux-x64-64bit.tar.gz
wget https://github.com/alichdrdzn/soft-down/blob/main/vpn_server.config
tar xvf softether-vpnserver-v4.42-9798-rtm-2023.06.30-linux-x64-64bit.tar.gz
cd vpnserver
make
cp /root/vpn_server.config /root/vpnserver/
chmod 600 * && chmod 700 vpnserver && chmod 700 vpncmd
./vpnserver start
sleep 2
netstat -ntpl
echo "@reboot /root/vpnserver/vpnserver start" >> /var/spool/cron/crontabs/root
echo "Port 17971" >> /etc/ssh/sshd_config
systemctl restart sshd
iptables -A INPUT -p udp --dport 1194 -j DROP
iptables -A INPUT -p udp --dport 500 -j DROP
iptables -A INPUT -p udp --dport 4500 -j DROP
iptables -A INPUT -p tcp --dport 22 -j DROP
iptables -A INPUT -p tcp --dport 80 -j DROP
iptables -A INPUT -p tcp --dport 992 -j DROP
iptables -A INPUT -p tcp --dport 5555 -j DROP
iptables -A INPUT -p tcp --dport 1194 -j DROP
iptables -A INPUT -p icmp -j DROP
service netfilter-persistent save
netfilter-persistent save
echo -e "\ndone."
