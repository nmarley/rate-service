# rate-service

An exchange rate API for converting rates between various fiat and
crypto-currency sources.

Abstracting this functionality to a separate service seemed like the best
design choice for various software projects that I've been working on.

Currently only uses Poloniex spot price and doesn't consider volume/VWAP, etc.,
so there's a bit of work to be done.

### Install

Clone this repo and run this cron command to fetch rates every minute:

    # m h  dom mon dow   command
    * * * * * /bin/bash <path-to-repo>/fetch-current-rates.sh >/dev/null 2>&1

Run the sinatra app using whatever deployment method:

    ruby rate.rb &

You can put this behind an nginx reverse proxy:

      upstream rate {
        server 127.0.0.1:4567;
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


### TODO

Can use Redis for caching rate info and make the cache time configurable.

Currently a bit "hacky", as it uses cron to fetch data from two JSON APIs and just sticks the files on disk. The Sinatra service loads the JSON files with every request.

