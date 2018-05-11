### lsync_csync2

```
cd /etc/
openssl req -x509 -newkey rsa:1024 -days 7200 \
-keyout /etc/csync2/csync2_ssl_key.pem -nodes \
-out /etc/csync2/csync2_ssl_cert.pem -subj '/CN=puppet'
csync2 -k /etc/csync2_puppet-group.key
chmod 0600 /etc/csync2_puppet-group.key
```

and store them to hiera or store as templates