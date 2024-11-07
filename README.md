# SSTP + Xray(x-ui panel) behind Cloudflare (using HaProxy)

SSTP Installation:
-------------------------------
```
bash <(curl -s -L https://raw.githubusercontent.com/alichdrdzn/sstp-v2ray/main/install.sh)
```
The script will ask you to set `username` and `password` to create a sstp user. and a `passphrase` for l2tp protocol.

>Once the script is finished, the basic necessary settings have been completed. 

You can now connect to the SSTP using the IP address.

Certificate Installation
-------------------------------
>You need a domain for this

Connect to the server using port 17971. and install certbot:
```
sudo snap install --classic certbot
```
**Issue a certificate:** \
First create two `A record` in Cloudflare for your two sub domains to point to your server \
one with `proxy off` and the other with `proxy on` option. After that run:
```
certbot certonly --standalone  --key-type rsa
```
The above command will ask you to set your domain name, <mark>set both DNS that you created in Cloudflare</mark>. \
To set certificate for your vpn server: 
1. execute vpncmd using `/root/vpnserver/vpncmd`
2. choose 1
3. go to the default hub using `HUB default'
4. run:
```
ServerCertSet
```
Enter the location of the certificate and its key, it should be something like: \
`/etc/letsencrypt/live/<domain-name>/fullchain.pem` and `/etc/letsencrypt/live/<domain-name>/privkey.pem` 
>Once the steps is finished, You can connect to the SSTP using the domain name. 

follow on to configure v2ray + sstp

In order to use V2ray you should change the sstp port:
```
ListenerDelete 443
```
```
ListenerCreate 30001
```
>The above command will modify the SSTP port. Therefore, from now on, you need to specify localhost:30001 as the hostname when connecting to vpncmd.

Exit the vpncmd.

Xray installtion
-------------------------------
```
bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh)
```
>The script will ask if you like to customize the panel settings, choose as you wish.

After Xray installation, we need to configure HaProxy in order to use port 443 for both Xray inbound and SSTP:
```
export DNSP=<replace-here-with-your-proxied-dns>
```
```
sed -i "s/dnsname/${DNSP}/g" /etc/haproxy/haproxy.cfg
```
```
systemctl enable haproxy && systemctl start haproxy
```
After enabling HaProxy, login to x-ui panel and go to `Panel Settings` \
Enter the location of the certificate and its key in `Public Key Path` and `Private Key Path`, then save and restart panel. \
Go to `Inbounds` and Add an inbound with this specification:

| Name         | Value |
| ---    | ---   |
| Port         |  8443   |
| Transmission | WebSocket   |
| Path         |  /ws   |
| Security     | TLS   |
| SNI          | DNS with Proxy   |
| Public Key and Private Key    | Set Cert from Panel   |

Now you can scan generated QR code for your inbound. \
**Important:** <mark>After scanning QR code you should change port from 8443 to 443 in your v2ray client.</mark> e.g: your phone or your pc. \
do not change it in panel.
<br><br>
PS: The script will generate a small game for your homepage. You can access it via a web browser.
![1](./web.png)
