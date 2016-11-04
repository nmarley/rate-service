# TODO

* replace reliance on shell/crontab/filesystem JSON with Redis cache
  - add a clock process which calls a worker to download API data every minute (sidekiq?)
  - use [Faraday](https://github.com/lostisland/faraday) with [Patron](https://github.com/toland/patron) or [Typhoeus](https://github.com/typhoeus/typhoeus) as the backend adapter for fetching these (I prefer Typhoeus as it's multi-headed, e.g. parallelized)

* load everything in app/workers/ (e.g. as currently in clock.rb) in some config/application or some environment setup file (init/boot?)

* conform to <http://jsonapi.org/> spec as much as possible
* remove dependency on BitcoinAverage (new API is closed-source & proprietary, funny timestamps)

