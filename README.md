[![Build Status](https://travis-ci.org/mperezi/docker-apache2-letsencrypt.svg?branch=master)](https://travis-ci.org/mperezi/docker-apache2-letsencrypt) [![Docker Pulls](https://img.shields.io/docker/pulls/mperezi/apache2-letsencrypt.svg)](https://hub.docker.com/r/mperezi/apache2-letsencrypt/)

# docker-apache2-letsencrypt

A Docker container running an out-of-the-box Apache2 web server with SSL enabled. You don't need to provide any previously-obtained certificate for your server because the issue of such certificate as well as the renewal are automatically handled by the Certbot client. 

# What is Certbot?
> [Certbot](https://certbot.eff.org) is an easy-to-use automatic client that fetches and deploys SSL/TLS certificates for your webserver. Certbot was developed by EFF and others as a client for Let's Encrypt and was previously known as "the official Let’s Encrypt client" or "the Let’s Encrypt Python client." 

# What is Let's Encrypt?
>[Let’s Encrypt](https://letsencrypt.org/about/) is a free, automated, and open certificate authority (CA), run for the public’s benefit. It is a service provided by the Internet Security Research Group (ISRG). 
>
>We give people the digital certificates they need in order to enable HTTPS (SSL/TLS) for websites, for free, in the most user-friendly way we can. We do this because we want to create a more secure and privacy-respecting Web.

# How to use this image

The base configuration file for the Apache web server (i.e. `httpd.conf`) has been tweaked to source a couple of external files that provide some extra configuration. These files are `httpd-vhosts.conf` and `httpd-ssl.conf` and they must reside in `/usr/local/apache2/conf/extra` inside the container. Because of that it's a good thing to:

1. Set up a folder structure like this in your host:

```bash
conf
└── extra
    ├── httpd-ssl.conf
    └── httpd-vhosts.conf
```

2. Mount the previous folder with `-v $PWD/conf/extra:/usr/local/apache2/conf/extra`.

## Set up your virtual hosts

The file `httpd-vhosts.conf` should contain the configuration for your virtual hosts. Here you usually specify the location of the certificate files as well as the automatic redirection from HTTP to HTTPS.

```
<VirtualHost *:80>
    ServerName mperezi.com
	Redirect permanent / https://mperezi.com/
</VirtualHost>

<VirtualHost *:443>
    ServerName mperezi.com
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/certs/cert.pem
    SSLCertificateKeyFile /etc/letsencrypt/certs/privkey.pem
    SSLCertificateChainFile /etc/letsencrypt/certs/chain.pem
</VirtualHost>
```

## Tune SSL-Related settings 

The file `httpd-ssl.conf` is where you place the settings that are specific to SSL.

```
Listen 443
SSLSessionCache shmcb:/usr/local/apache2/logs/ssl_scache(512000)
```

## Run the container

### Docker CLI

```bash
$ docker volume create certs

$ docker container run \
  -d
  -p 80:80
  -p 443:443
  --hostname <domain-to-be-secured.com>
  -e LETS_ENCRYPT_EMAIL <maintainer-of-the-domain@mail-server.com>
  -v $PWD/html:/usr/local/apache2/htdocs
  -v $PWD/conf/extra:/usr/local/apache2/conf/extra
  -v certs:/etc/letsencrypt
  --name web 
  mperezi/apache2-letsencrypt
```

### Docker Compose

```yaml
version: '2'

services:
  web:
    image: mperezi/apache2-letsencrypt
    hostname: <domain-to-be-secured.com>
    ports:
      - '80:80'
      - '443:443'
    environment:
      LETS_ENCRYPT_EMAIL: <maintainer-of-the-domain@mail-server.com>
    volumes:
      - '$PWD/html:/usr/local/apache2/htdocs'
      - '$PWD/conf/extra:/usr/local/apache2/conf/extra'
      - 'certs:/etc/letsencrypt'

volumes:
  certs:
```

# FAQ

## Where are my certificates?

All generated keys and issued certificates can be found in `/etc/letsencrypt/live/<domain>` inside the container. It's advisable to use a volume and mount `/etc/letsencrypt` to prevent certificate loss upon successive restarts of the container.

You can query Certbot at any time and obtain valuable information about the certificates installed in the container by using:

```bash
$ docker container exec web certbot certificates
Found the following certs:
  Certificate Name: example.com
    Domains: example.com, www.example.com
    Expiry Date: 2017-02-19 19:53:00+00:00 (VALID: 30 days)
    Certificate Path: /etc/letsencrypt/live/example.com/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/example.com/privkey.pem
```

## What about renewal?

You don't need to worry about expiry dates or renewing your certificates because Certbot does it for you too. And it does so by setting up a cron job that runs the command `certbot renew` (usually twice a day). This command attempts to renew any previously-obtained certificates that expire in less than 30 days. 

## Besides example.com I also want to secure smtp.example.com, blog.example.com, ...

You can obtain a certificate for as many domains as you want by setting the environment variable `LETS_ENCRYPT_DOMAINS`. By providing a comma-separated list of domains there you get a certificate where:

> The first domain provided will be the subject CN of the certificate, and all domains will be Subject Alternative Names on the certificate. 

The first domain refers to the `hostname` of the container.