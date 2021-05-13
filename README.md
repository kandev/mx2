# Simple and clean backup mail server #
This is backup incoming spooler mail server. Made to work somewhere in the wild buffering incoming email while the primary server is not accessible.

## Installation ##
### Build from source ###
```
git clone https://github.com/kandev/mx2
cd mx2
docker-compose build
docker-compose up -d
```
### Get the latest image from Docker Hub ###
```
docker create -h mx2 --name mx2 -v /etc/localtime:/etc/localtime:ro kandev/mx2:latest
docker start mx2
```

## Configuration ##

### Obtain SSL Certificate ###
Initial creation of the certificate is manual.
```
certbot certonly --agree-tos -n --standalone -d mail.domain.tld
```
Daily cron job is running to automatically renew any expiring certificates.

### Postfix main.cf ###
Update **myhostname**, **proxy_interfaces** and **relay_domains** in **/etc/postfix/main.cf**.

### Final notes ###
I have included SPF filter, some of the most reliable black lists and basic sender filter which should be enough to keep the major part of the spam away.
You should add mx2's IP to **mynetworks** or SPF whitelist on your primary mail server.
