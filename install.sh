#!/bin/bash
apt update && apt install tcpdump htop build-essentials -y
wget https://github.com/alichdrdzn/soft-down/blob/main/softether-vpnserver-v4.42-9798-rtm-2023.06.30-linux-x64-64bit.tar.gz
wget https://github.com/alichdrdzn/soft-down/blob/main/vpn_server.config
tar xfv softether-vpnserver-v4.42-9798-rtm-2023.06.30-linux-x64-64bit.tar.gz
cd vpnserver
make
cp /root/vpn_server.config ./
chmod 600 * && chmod 700 vpnserver && chmod 700 vpncmd
./vpnserver start
sleep 2
netstat -ntpl
