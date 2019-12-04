FROM debian:buster-slim

LABEL maintainer="Miguel Pérez <https://github.com/mperezi>"

RUN apt-get update && \
	apt-get -y install python-certbot-apache cron rsyslog

# Add periodic renew task of certificates
RUN crontab /etc/cron.d/certbot

# Enable cron logs via rsyslog
RUN sed -i \
    -e 's,^#\(cron.*\)$,\1,' \
    -e 's,^\(module.*imklog.*\)$,#\1,' \
    /etc/rsyslog.conf

COPY launcher.sh /usr/local/bin/launcher.sh
RUN chmod +x /usr/local/bin/launcher.sh

CMD ["/usr/local/bin/launcher.sh"]
