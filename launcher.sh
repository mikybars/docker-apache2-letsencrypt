#!/bin/bash

LETS_ENCRYPT_ETC="/etc/letsencrypt"
LETS_ENCRYPT_ROOT_DOMAIN=$(hostname -f)

certificate_exists_for() {
	test -e "$LETS_ENCRYPT_ETC/live/$1/privkey.pem"
}

echo "Checking certificates..."
if [ ! certificate_exists_for $LETS_ENCRYPT_ROOT_DOMAIN ]; then
	echo "No certificate found for $LETS_ENCRYPT_ROOT_DOMAIN"

	[ -z "$LETS_ENCRYPT_DOMAINS" ] || LETS_ENCRYPT_ADDITIONAL_DOMAINS="--domains $LETS_ENCRYPT_DOMAINS"

	certbot certonly \
		--apache  \
		--non-interactive \
		--no-self-upgrade \
		--agree-tos \
		--email $LETS_ENCRYPT_EMAIL \
		--domain $LETS_ENCRYPT_ROOT_DOMAIN \
		$LETS_ENCRYPT_ADDITIONAL_DOMAINS

	# see conf/extra/httpd-vhosts.conf
	ln -s $LETS_ENCRYPT_ETC/live/$LETS_ENCRYPT_ROOT_DOMAIN $LETS_ENCRYPT_ETC/certs
else
	echo "Certificate found for $LETS_ENCRYPT_ROOT_DOMAIN"
	certbot certificates --cert-name $LETS_ENCRYPT_ROOT_DOMAIN
	certbot renew --no-self-upgrade
fi

echo "Launching apache2."
httpd-foreground
