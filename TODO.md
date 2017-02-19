# TODO

* make the rake redis:populate task into an endpoint instead, then just hit the
  endpoint via cron every minute

* implement "old" or "stale" namespace for use in loading new values

  (hint: [rename](http://redis.io/commands/rename) old values just before a new
  load, and then implement a back-off strategy for all Redis data GET's, e.g.
  first fetch cross pair, if not found, fetch the regular values and if
  "regular" values not found, fetch the "stale" namespace values. If still not
  found, they don't exist.)

### DEPLOYMENT VIA DOCKER

Finish docker-compose networking bits, ensure that app container can access redis container via 'redis' name, then set an ENV var 'REDIS_URL' in docker-compose file:

    REDIS_URL="redis://redis:6379/0"

# REDIS_URL="redis://172.17.0.2:6379/0"
# REDIS_URL="redis://172.17.0.2:6379/0" bundle exec puma -C config/puma.rb config.ru


# ==============================================================================

* proper Sinatra service tests via Rack::Test <http://www.sinatrarb.com/testing.html>, <http://www.sinatrarb.com/configuration.html>

* implement proper HTTP status codes (e.g. 404 for "Not Found" if a FX code/pair is not found or upon invalid route)

* cache calculated cross-pairs in Redis (e.g. DASH/USD, GBP/BTC, etc.)

* make a class which re-uses a single Redis(::Namespace) connection and implement all "helper" methods (e.g. `is_fiat`, `usd_crypto`, etc) as methods on that class

* use [Faraday](https://github.com/lostisland/faraday) with [Patron](https://github.com/toland/patron) or [Typhoeus](https://github.com/typhoeus/typhoeus) as the backend adapter for fetching these (I prefer Typhoeus as it's multi-headed, e.g. parallelized)

* conform to <http://jsonapi.org/> spec as much as possible

* remove dependency on BitcoinAverage (new API is closed-source & proprietary, funny timestamps)
