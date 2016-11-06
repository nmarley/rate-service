# TODO

* make a class which re-uses a single Redis(::Namespace) connection and implement all "helper" methods (e.g. `is_fiat`, `usd_crypto`, etc) as methods on that class

* use [Faraday](https://github.com/lostisland/faraday) with [Patron](https://github.com/toland/patron) or [Typhoeus](https://github.com/typhoeus/typhoeus) as the backend adapter for fetching these (I prefer Typhoeus as it's multi-headed, e.g. parallelized)

* conform to <http://jsonapi.org/> spec as much as possible

* remove dependency on BitcoinAverage (new API is closed-source & proprietary, funny timestamps)

