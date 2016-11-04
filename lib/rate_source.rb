require 'faraday'
require 'uri'
require 'redis'
require 'json'
require 'pp'
require 'awesome_print'
require 'byebug'

class RateSource
  attr_reader :redis

  def initialize(redis)
    @redis = redis
  end

  def fetch
    u = URI.parse(api_url)
    url = u.scheme + "://" + u.host

    conn = Faraday.new(url: url) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter # Net::HTTP
    end
    resp = conn.get u.request_uri

    return post_process(resp.body)
  end

  def post_process(data)
    return data
  end

  def load(hash)
    hash.each do |key, val|
      redis.set key, val
    end
  end

  def fetch_and_load
    load fetch
  end

  def api_url; end
end

class PoloniexAPI < RateSource
  API_URL = 'https://poloniex.com/public?command=returnTicker'

  def api_url
    return API_URL
  end

  def post_process(data)
    h = JSON.parse(data)
    newhash = Hash.new

    # ignore non-BTC markets
    h.keep_if { |k,v| k.match(/^BTC_/) }
    h.each do |k,v|
      newkey = k
      newval = v['last']
      newhash[newkey] = newval
    end

    # Bitcoin in terms of Bitcoin
    newhash['BTC_BTC'] = '1'

    return newhash
  end
end

class BitcoinAverageAPI < RateSource
  API_URL = 'https://apiv2.bitcoinaverage.com/constants/exchangerates/global'

  def api_url
    return API_URL
  end

  def post_process(data)
    h = JSON.parse(data)
    newhash = Hash.new

    # remove precious metals and SDRs
    %w[ XAG XAU XDR XPD XPT ].each do |tick|
      h['rates'].delete(tick)
    end

    h['rates'].each do |k,v|
      newkey = "USD_#{k}"
      newval = v['rate']
      newhash[newkey] = newval
    end

    return newhash
  end
end

