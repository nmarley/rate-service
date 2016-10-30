require 'sinatra/base'
require 'sinatra/json'
require 'json'
require 'bigdecimal'
require 'bigdecimal/util'
require 'pp'
require 'awesome_print'
require 'httparty'

# Microservice REST API for Dash price to whatever FIAT currency, and BTC.
#
# Input: FX Pair
# Output: Returns exchange rate
#
# Future: Stick this into a DB/Redis, pull rate every X seconds. Then write out
# static files for each currency pair and serve up JSON files directly via
# nginx. This should scale like crazy.

# TODO: separate exchange rate logic & sinatra service

# previously: load_btc_fiat
def load_bitcoinaverage
  # https://api.bitcoinaverage.com/ticker/global/all
  h = JSON.parse(File.read('ba_global_all.json'))
  h.delete("BTC")
  ts = h.delete("timestamp")
  return h
end

def load_poloniex
  # https://poloniex.com/public?command=returnTicker
  h = JSON.parse(File.read('polo.json'))

  # poloniex lists the fx pairs backwards... correct them
  h = h.map { |k,v| [ k.split(/_/).reverse.join('_') , v ] }.to_h
  h
end

::TICKER_CHANGES = {
  'XBT' => 'BTC',
  'DRK' => 'DASH',
}

def normalize_ticker_string(ticker)
  ::TICKER_CHANGES.has_key?(ticker) ? ::TICKER_CHANGES[ticker] : ticker
end

def make_payload(h)
  payload = {}

  if h.has_key?(:err)
    payload = { success: false, error: h[:err] }
  else
    payload = { success: true, quote: h[:pair], rate: h[:rate].to_f.round(8) }
  end

  return payload.to_json
end

def is_fiat(currency)
  h = load_bitcoinaverage
  h.keys.include?(currency)
end

# TODO: fix
def is_crypto(currency)
  h = load_poloniex
  poloniex_alts = h.keys.grep(/^_BTC/).map { |e| e.sub(/^_BTC/, '') }
  # others = %w[ BTC XBT ]
  poloniex_alts.include?(currency)
end

def poloniex_has_pair(fxpair)
  h = load_poloniex
  h.has_key?(fxpair)
end

def poloniex_pair(fxpair)
  h = load_poloniex
  h[fxpair]['last']
end

def btc_fiat_rate(currency)
  h = load_bitcoinaverage
  h[currency]['last']
end

def get_rates(fxpair)
  base, quote = fxpair.split /_/

  # standardize any inconsistencies in currency ticker names
  base  = normalize_ticker_string(base)
  quote = normalize_ticker_string(quote)
  fxpair = base + '_' + quote

  # do the thing
  if (base === quote)
    payload = make_payload(pair: fxpair, rate: 1)

  elsif (is_fiat(base))
    payload = make_payload(err: 'Fiat base pairs are not supported.')

  elsif (poloniex_has_pair(fxpair))
    payload = make_payload(pair: fxpair, rate: poloniex_pair(fxpair))

  elsif (is_crypto(quote) && is_crypto(base))
    # in this case, both are alt crypto.
    # get BTC_<alt> rate for each & divide...
    base_rate  = poloniex_pair(base + '_BTC').to_d
    quote_rate = poloniex_pair(quote + '_BTC').to_d
    rate = base_rate.to_d * (1 / quote_rate)
    payload = make_payload(pair: fxpair, rate: rate)

  elsif (is_fiat(quote))
    if (base === 'BTC')
      rate = btc_fiat_rate(quote).to_d
    else
      rate = poloniex_pair(base + '_BTC').to_d * btc_fiat_rate(quote).to_d
    end
    payload = make_payload(pair: fxpair, rate: rate)

  else
    payload = make_payload(err: "FX Pair [#{fxpair}] unsupported.")
  end

  return payload
end


class RateService < Sinatra::Base
  set :port, 4568

  # enable .json extension
  get '/rate/:fxpair.json' do
    content_type :json
    return get_rates(params[:fxpair].strip.upcase)
  end

  # default without extension
  get '/rate/:fxpair' do
    content_type :json
    return get_rates(params[:fxpair].strip.upcase)
  end

  # $0 is the executed file
  # __FILE__ is the current file
  run! if __FILE__ == $0
end
