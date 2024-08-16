# SSTP + V2RAY behind Cloudflare (using HaProxy)
\
**SSTP Installation:**
```
bash <(curl -s -L https://raw.githubusercontent.com/alichdrdzn/soft-down/main/install.sh)
```
After installation is complete, connect to the server using port 17971. \
Start the vpn utility using: `/root/vpnserver/vpncmd`, This will be run an interactive sstp configuration utility (vpncmd utility), Choose 1.

In the vpncmd run these commands in order:
```
 hub default
```
```
 ipsecenable
```
```
 securenatenable
```
```
 sstpenable
```
```
 usercreate
```
```
userpasswordset
```  
The basic necessary settings have been completed; now you can connect to the server using the IP address. 


**CERTIFICATE Installation. (You need a domain for this)** \
Install certbot:
```
sudo snap install --classic certbot
```
Issue a certificate:
First set an A record in Cloudflare for your domain to point to your server(Proxy off).
the run:
```
certbot certonly --standalone  --key-type rsa
```
To set certificate for your vpn server, execute vpn utility and go to the default hub. then run:
```
ServerCertSet
```
Enter the location of the certificate and its key, it should be something like: \
`/etc/letsencrypt/live/<domain-name>/fullchain.pem and /etc/letsencrypt/live/<domain-name>/privkey.pem` \
In order to use V2ray you should change the sstp port:
```
ListenerDelete 443
```
```
ListenerCreate 30001
```


**v2ray installtion**
```
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```
First set another A record in Cloudflare for your domain to point to your server (**use proxy option**). \
After that run:
```
export DNS=<replace-here-with-your-proxied-dns>
```
```
sed "s/dnsname/${DNS}/g" /etc/haproxy/haproxy.cfg
```
```
systemctl enable haproxy && systemctl start haproxy
```

After installation login to panel and go to  `Panel Settings` and Enter the location of the certificate and its key in `Public Key Path` and `Private Key Path`, then save and restart panel. \
Go to `Inbounds` and Add an inbound with this specification:

| Name         | Value |
| ---    | ---   |
| Port         |  8443   |
| Transmission | WebSocket   |
| Path         |  /ws   |
| Security     | TLS   |
| SNI          | DNS with Proxy   |
| Public Key and Private Key    | Set Cert frop Panel   |

Now you can scan v2ray QR code. \
**Important: After scanning QR code you should change port from 8443 to 443 in your v2ray client. e.g: your phone or your pc.** do not change it in panel.
