#!/usr/bin/env bash

echo "Checking certificates"
if [ ! -e /etc/letsencrypt/live/$(hostname -f)/privkey.pem ]; then
	echo "No certificate found for $(hostname -f)"

	if [ -n $LETS_ENCRYPT_DOMAINS ]; then
		LETS_ENCRYPT_DOMAINS="-d $(echo $LETS_ENCRYPT_DOMAINS | sed -e 's/,/ -d /g')"
	fi

	certbot certonly \
		--apache  \
		--non-interactive \
		--no-self-upgrade \
		--agree-tos \
		--email $LETS_ENCRYPT_EMAIL \
		$LETS_ENCRYPT_DOMAINS
	ln -s /etc/letsencrypt/live/$(hostname -f) /etc/letsencrypt/certs
else
	echo "Certificate found for $(hostname -f)"
	certbot renew --no-self-upgrade
fi

echo "Launching apache2."
httpd-foreground
