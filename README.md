# Apache2 with SSL
Docker image setting up Apache2 with SSL enabled via Let's Encrypt

# Usage

```bash
$ docker container run \
  -d
  -p 80:80
  -p 443:443
  --hostname <my-domain.com>
  -e LETS_ENCRYPT_EMAIL <email@email.com>
  
  mperezi/apache2-ssl
```

## docker-compose.yml

```yaml
version: '2'

services:
  https:
    build: .
    image: mperezi/apache2-ssl
    hostname: mperezi.com
    ports:
      - '80:80'
      - '443:443'
    environment:
      LETS_ENCRYPT_EMAIL: "mperezibars@gmail.com"
    volumes:
      - '$PWD/html:/usr/local/apache2/htdocs'
      - '$PWD/conf/extra:/usr/local/apache2/conf/extra'
      - 'certs:/etc/letsencrypt'

volumes:
  certs:
```
