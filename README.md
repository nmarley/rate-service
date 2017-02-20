# rate-service

An exchange rate API for converting rates between various fiat and
crypto-currency sources.

Abstracting this functionality to a separate service seemed like the best
design choice for various software projects that I've been working on.

Currently only uses Poloniex spot price and doesn't consider volume/VWAP, etc.,
so there's a bit of work to be done.

### Deployment via Docker

0. Install docker and docker-compose.  Note that Ubuntu is notoriously slow in
their package release process, and because of this, the docker-compose
installed with `apt-get` on Ubuntu 16.10 won't work with this setup. I
recommend installing the latest `docker-compose` ELF binary which is available
on Github.

1. Clone the repo:

    git clone https://github.com/nmarley/rate-service.git && cd rate-service

2. Create the environment variables file `nginx-variables.env` with the appropriate values:

    ```
    NGINX_HOST=FQDN
    NGINX_SSL_CERT=/ssl/rates.cer
    NGINX_SSL_KEY=/ssl/rates.key
    NGINX_DHPARAM=/ssl/dh2048.pem
    ```

3. Add SSL certificate info to /data/ssl on the host machine (or alter the
   docker-compose.yml file accordingly). You can generate a DH params file by:
   `openssl dhparam -out dh2048.pem 2048`. Obtain SSL certificates in the usual
   manner (I recommend Let's Encrypt).

4. Start all containers:

    docker-compose up

5. Ensure a scheduled cron (or other) job is calling this API endpoint every
   minute, in order to pull the latest exchange rate data:

    http://<service>/service/ingest

Example:

  curl -I http://localhost/service/ingest;echo

The endpoint doesn't have to be called from the Docker host -- it can be reached from anywhere.

That's it! Make sure and test the configuration.

### Install via traditional manner

Clone this repo and install gems:

    git clone https://github.com/nmarley/rate-service.git && cd rate-service
    bundle install --binstubs --path vendor

Also install & run Redis on the standard port.

Run this cron command to fetch rates every minute:

    # m h  dom mon dow   command
    * * * * * /bin/bash <path-to-repo>/fetch-current-rates.sh >/dev/null 2>&1

Run the sinatra app using whatever deployment method:

    bundle exec puma -C config/puma.rb config.ru &

You can put this behind an nginx reverse proxy:

      upstream rate {
        server 127.0.0.1:4568;
      }

      server {
          server_name rates.example.com;
          listen 80;

          location /rate {
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
            proxy_redirect off;
            proxy_pass http://rate;
          }
      }

