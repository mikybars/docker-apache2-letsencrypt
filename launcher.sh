#!/bin/bash

LETS_ENCRYPT_ROOT_DOMAIN=$(hostname -f)
SLEEP_INTERVAL_IN_SECONDS=60

service cron start
service rsyslog start

check_apache_status_loop() {
	echo "Monitoring apache2 status..."
	while service apache2 status >/dev/null; do
		sleep $SLEEP_INTERVAL_IN_SECONDS
	done

	echo "Service apache2 is no longer running... Exiting"
}

# Enable our sites configuration (see /etc/apache2/sites-available)
a2ensite "*.conf"

echo
echo "Checking certificates for $LETS_ENCRYPT_ROOT_DOMAIN"
echo

if [ -n "$LETS_ENCRYPT_DOMAINS" ]; then 
	LETS_ENCRYPT_ADDITIONAL_DOMAINS="--domains $LETS_ENCRYPT_DOMAINS"
fi

certbot run \
		--apache  \
		--non-interactive \
		--no-self-upgrade \
		--agree-tos \
		--email $LETS_ENCRYPT_EMAIL \
		--domain $LETS_ENCRYPT_ROOT_DOMAIN \
		$LETS_ENCRYPT_ADDITIONAL_DOMAINS

check_apache_status_loop
