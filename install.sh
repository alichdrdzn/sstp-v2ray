#!/bin/bash
apt update && apt install tcpdump htop build-essential netfilter-persistent speedtest-cli snapd dnsutils haproxy -y
wget http://www.softether-download.com/files/softether/v4.42-9798-rtm-2023.06.30-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-v4.42-9798-rtm-2023.06.30-linux-x64-64bit.tar.gz
wget https://github.com/alichdrdzn/soft-down/blob/main/vpn_server.config
tar xvf softether-vpnserver-v4.42-9798-rtm-2023.06.30-linux-x64-64bit.tar.gz
cd vpnserver
make
mkdir -p hamcore/wwwroot
curl -o /root/vpnserver/hamcore/wwwroot/index.html -s -L https://raw.githubusercontent.com/alichdrdzn/sstp-v2ray/main/index.html
chmod 600 * && chmod 700 vpnserver && chmod 700 vpncmd
curl -o /etc/haproxy/haproxy.cfg -s -L  https://raw.githubusercontent.com/alichdrdzn/sstp-v2ray/main/haproxy.cfg
systemctl disable haproxy && systemctl stop haproxy
./vpnserver start
cat <<EOF > commands.txt
HUB default
IPsecEnable /L2TP:yes /L2TPRAW:yes /ETHERIP:yes /PSK:pskey  /DEFAULTHUB:default
SecureNatEnable
SstpEnable yes
UserCreate cuser /GROUP:none /REALNAME:none /NOTE:none
UserPasswordSet cuser /PASSWORD:upass
EOF
echo -e "\n\nCreating a sstp user...."
read -p "Enter an username: " cuser
read -p "Enter a password for ($cuser): " upass
echo -e "\n\nConfiguring...."
read -p "Enter a Pass phrase key for l2tp: " pskey
sed -i "s/pskey/${pskey}/g" /root/vpnserver/commands.txt 1>/dev/null
sed -i "s/cuser/${cuser}/g" /root/vpnserver/commands.txt 1>/dev/null
sed -i "s/upass/${upass}/g" /root/vpnserver/commands.txt 1>/dev/null
./vpncmd localhost /SERVER /HUB default /PASSWORD: /IN:commands.txt
sed -i "s/${cuser}/cuser/g" /root/vpnserver/commands.txt 1>/dev/null
sed -i "s/${upass}/upass/g" /root/vpnserver/commands.txt 1>/dev/null
sed -i "s/${pskey}/pskey/g" /root/vpnserver/commands.txt 1>/dev/null
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
echo -e "\ndone."
systemctl restart sshd
