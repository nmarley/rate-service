require 'byebug'
require 'bigdecimal'
require 'bigdecimal/util'
require 'json'
require 'pp'
require 'awesome_print'
require 'redis'

module RateHelpers
  def is_fiat(ticker)
    ticker = ticker.upcase.strip
    return false  if ticker === 'BTC' 

    # this is the fix for O(1) lookup speed
    nk = "USD_#{ticker.upcase.strip}"
    return !($redis.get(nk).nil?)
  end

  def is_crypto(ticker)
    ticker = ticker.upcase.strip
    nk = "BTC_#{ticker}"
    return !($redis.get(nk).nil?)  # || (ticker === 'BTC')
  end

  TICKER_CHANGES = {
    'XBT' => 'BTC',
    'DRK' => 'DASH',
    'DSH' => 'DASH',
  }

  def normalize_ticker_string(ticker)
    TICKER_CHANGES.has_key?(ticker) ? TICKER_CHANGES[ticker] : ticker
  end

  def is_valid_ticker_string(ticker_string)
    return is_fiat(ticker_string) || is_crypto(ticker_string)
  end
end
