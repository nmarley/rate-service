require 'byebug'
require 'bigdecimal'
require 'bigdecimal/util'
require 'json'
require 'pp'
require 'awesome_print'
require 'redis'

def load_bitcoinaverage(redis, data)
  h = JSON.parse(data)

  # remove precious metals and SDRs
  %w[ XAG XAU XDR XPD XPT ].each do |tick|
    h['rates'].delete(tick)
  end

  # flush all current USD keys -- need a better way of implementing updates
  fiat_keys = redis.keys('USD_*')
  fiat_keys.each do |key|
    redis.del key
  end

  h['rates'].each do |k,v|
    newkey = "USD_#{k}"
    newval = v['rate']
    puts "newkey = [#{newkey}], v = [#{newval}]"

    redis.set newkey, newval
  end

end

redis = Redis.new

# load data into Redis
fn = 'ba2_global_all.json'
data = File.read(fn)
load_bitcoinaverage(redis, data)

