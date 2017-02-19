# rate-service

An exchange rate API for converting rates between various fiat and
crypto-currency sources.

Abstracting this functionality to a separate service seemed like the best
design choice for various software projects that I've been working on.

Currently only uses Poloniex spot price and doesn't consider volume/VWAP, etc.,
so there's a bit of work to be done.

### Install

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

