FROM ubuntu:latest
MAINTAINER Todor Kandev <todor@kandev.com>
ARG DEBIAN_FRONTEND=noninteractive

ENV MYHOSTNAME mx2.domain.tld
ENV LANG en_US.utf8

RUN \
  apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
    postfix \
    opendkim \
    postfix-policyd-spf-python \
    postfix-pcre\
    coreutils \
    bash \
    supervisor \
    ca-certificates \
    certbot \
    locales \
    inetutils-syslogd \
    cron \
    curl \
    vim \
    openssh-server \
    inetutils-ping \
    dumb-init cpio whois >/dev/null && \
  apt-get -qq autoclean && \
  apt-get -qq clean
RUN \
  mkdir /root/.ssh && \
  mkdir /run/sshd && \
  cp /etc/services /var/spool/postfix/etc/ && \
  cp /etc/resolv.conf /var/spool/postfix/etc/ && \
  cp /etc/host.conf /var/spool/postfix/etc/ && \
  cp /etc/hosts /var/spool/postfix/etc/ && \
  cp /etc/localtime /var/spool/postfix/etc/ && \
  cp /etc/nsswitch.conf /var/spool/postfix/etc/ && \
  echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1hQH5HHB8U2PUbUn7nwYUHm0jdz3URoFdYZY1+QSVk" > /root/.ssh/authorized_keys && \
  sed -i 's/?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
  sed -i 's/?PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
  echo '0 6 * * * certbot renew -n --standalone' > /etc/cron.d/certbot-renew && \
  localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

COPY ./files/supervisord.conf /etc/supervisor/supervisord.conf
COPY ./files/master.cf /etc/postfix/master.cf
COPY ./files/main.cf /etc/postfix/main.cf
COPY ./files/letsencrypt/ /etc/letsencrypt/

EXPOSE 22 25 80
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

