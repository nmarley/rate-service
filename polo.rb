require 'byebug'
require 'bigdecimal'
require 'bigdecimal/util'
require 'json'
require 'pp'
require 'awesome_print'
require 'redis'

$redis = Redis.new

def is_crypto(ticker)
  nk = "BTC_#{ticker.upcase.strip}"
  return !($redis.get(nk).nil?) || (ticker.upcase.strip === 'BTC')
end

%w[ cny xbt btc dash eth etc maid xmr ].each do |t|
  puts "t = #{t}, is_crypto(#{t}) = #{is_crypto(t)}"
end

