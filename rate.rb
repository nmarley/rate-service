require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/cross_origin'
require 'json'
require 'bigdecimal'
require 'bigdecimal/util'
require 'pp'
require 'awesome_print'
require 'byebug'
require File.expand_path('config/application', __dir__)
require 'rate_helpers'
require 'rate_service'

# TODO: class with all this encapsulated
include RateHelpers

# Microservice REST API for Dash price to whatever FIAT currency, and BTC.
#
# Input: FX Pair
# Output: Returns exchange rate
#

def make_payload(h)
  payload = {
    server_ts: Time.now.getutc.xmlschema,
  }

  if h.has_key?(:err)
    payload.merge!({success: false, error: h[:err]})
  else
    payload.merge!({success: true, quote: h[:pair], rate: h[:rate].round(8).to_s('8F')})
  end

  return payload.to_json
end


# fetch the rate info from DB, calculate & return
def get_rates(fxpair)
  base, quote = fxpair.split /_/

  # standardize any inconsistencies in currency ticker names
  base  = normalize_ticker_string(base)
  quote = normalize_ticker_string(quote)
  fxpair = base + '_' + quote

  # check validity of base/quote
  if (not is_valid_ticker_string($redis, base))
    return make_payload(err: "#{base} is not a valid currency ticker string")
  end
  if (not is_valid_ticker_string($redis, quote))
    return make_payload(err: "#{quote} is not a valid currency ticker string")
  end

  rate = get_rate($redis, base, quote)
  return make_payload(pair: fxpair, rate: rate)
end


module RateService
  class App < Sinatra::Base
    before do
      content_type :json
    end

    # /rate/:fxpair(.ext)?
    get '/rate/:fxpair.?:format?' do
      return get_rates(params[:fxpair].strip.upcase)
    end

    get '/service/ingest.?:format?' do
      begin
        RateService.ingest
        status 204
      rescue StandardError => ex
        status 500
        body make_payload(err: ex.message)
      end
    end

    get '/*' do
      return make_payload(err: "Sorry, that path is not defined.")
    end

    # $0 is the executed file
    # __FILE__ is the current file
    run! if __FILE__ == $0
  end
end
