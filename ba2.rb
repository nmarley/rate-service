require 'byebug'
require 'bigdecimal'
require 'bigdecimal/util'
require 'json'
require 'pp'
require 'awesome_print'
require 'redis'

$redis = Redis.new

def is_fiat(ticker)
  ticker.upcase!.strip!
  # currently this is O(N) -- need to switch to redis.get, which is O(1)
  # this should make lookups blazing fast
  fiat_tickers = $redis.keys('USD_*').map { |elem| elem.sub(/^USD_/, '') }
  fiat_tickers.delete('BTC') # BTC should not be counted as 'fiat'...
  return fiat_tickers.include?(ticker)

  # this is the fix for O(1) lookup speed
  # (byebug) nk = "USD_#{ticker.upcase.strip}"
  # return !($redis.get(nk).nil?)
end

byebug
t = 'cny'
puts "t = #{t}, is_fiat(#{t}) = #{is_fiat(t)}"
