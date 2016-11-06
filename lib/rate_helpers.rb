require 'byebug'
require 'bigdecimal'
require 'bigdecimal/util'
require 'json'
require 'pp'
require 'awesome_print'
require 'redis'

module RateHelpers
  def is_fiat(redis, ticker)
    ticker = ticker.upcase.strip
    return false  if ticker === 'BTC'

    # this is the fix for O(1) lookup speed
    nk = "USD_#{ticker.upcase.strip}"
    return !(redis.get(nk).nil?)
  end

  def is_crypto(redis, ticker)
    ticker = ticker.upcase.strip
    nk = "BTC_#{ticker}"
    return !(redis.get(nk).nil?)  # || (ticker === 'BTC')
  end

  def btc_fiat(redis, fiat)
    key = "USD_#{fiat}"
    usd_fiat = BigDecimal.new(redis.get(key))
    btc_usd = 1 / BigDecimal.new(redis.get('USD_BTC'))
    return (btc_usd * usd_fiat)
  end

  def btc_crypto(redis, crypto)
    key = "BTC_#{crypto}"
    return BigDecimal.new(redis.get(key))
  end

  def usd_crypto(redis, crypto)
    key = "BTC_#{crypto}"
    btc_crypto = BigDecimal.new(redis.get(key))
    usd_btc = BigDecimal.new(redis.get('USD_BTC'))
    return (usd_btc * btc_crypto)
  end

  def usd_fiat(redis, fiat)
    key = "USD_#{fiat}"
    return BigDecimal.new(redis.get(key))
  end

  TICKER_CHANGES = {
    'XBT' => 'BTC',
    'DRK' => 'DASH',
    'DSH' => 'DASH',
  }

  def normalize_ticker_string(ticker)
    return TICKER_CHANGES.has_key?(ticker) ? TICKER_CHANGES[ticker] : ticker
  end

  def is_valid_ticker_string(ticker_string)
    return is_fiat(ticker_string) || is_crypto(ticker_string)
  end
end
