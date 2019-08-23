FROM httpd
LABEL maintainer="Miguel Pérez <https://github.com/mperezi>"

RUN printf "deb http://deb.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/backports.list && \
	apt-get update && \
	apt-get -y install certbot python-certbot-apache cron rsyslog -t stretch-backports

# Add periodic renew task of certificates
RUN crontab /etc/cron.d/certbot

# Enable cron logs via rsyslog
RUN sed -i \
    -e 's,^#\(cron.*\)$,\1,' \
    -e 's,^\(module.*imklog.*\)$,#\1,' \
    /etc/rsyslog.conf

# Enable HTTPS support in Apache
RUN sed -i \
	-e 's/^#\(LoadModule .*mod_ssl.so\)/\1/' \
	-e 's/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/' \
	-e 's/^#\(Include .*vhosts.conf\)/\1/' \
	-e 's/^#\(Include .*ssl.conf\)/\1/' \
	conf/httpd.conf

COPY launcher.sh /usr/local/bin/launcher.sh
RUN chmod +x /usr/local/bin/launcher.sh

CMD ["/usr/local/bin/launcher.sh"]
