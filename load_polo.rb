require 'byebug'
require 'bigdecimal'
require 'bigdecimal/util'
require 'json'
require 'pp'
require 'awesome_print'
require 'redis'

def load_poloniex(redis, data)
  h = JSON.parse(data)

  # ignore non-BTC markets
  h.keep_if { |k,v| k.match(/^BTC_/) }

  # flush all current BTC keys -- need a better way of implementing updates
  crypto_keys = redis.keys('BTC_*')
  crypto_keys.each do |key|
    redis.del key
  end

  h.each do |k,v|
    newkey = k
    newval = v['last']
    puts "newkey = [#{newkey}], v = [#{newval}]"
    redis.set newkey, newval
  end
end


redis = Redis.new

# load data into Redis
fn = 'polo.json'
data = File.read(fn)
good = load_poloniex(redis, data)


