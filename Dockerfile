FROM httpd

RUN printf "deb http://deb.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/backports.list && \
	apt-get update && \
	apt-get -y install vim nmap certbot python-certbot-apache -t stretch-backports

RUN sed -i \
	-e 's/^#\(LoadModule .*mod_ssl.so\)/\1/' \
	-e 's/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/' \
	-e 's/^#\(Include .*vhosts.conf\)/\1/' \
	-e 's/^#\(Include .*ssl.conf\)/\1/' \
	conf/httpd.conf

COPY launcher.sh /usr/local/bin/launcher.sh
RUN chmod +x /usr/local/bin/launcher.sh

CMD ["/usr/local/bin/launcher.sh"]
