require 'redis'
require 'bigdecimal'
require 'bigdecimal/util'

class BigDecimal
  # "easy print"
  def ep(num=8)
    round(num).to_s("#{num}F")
  end
end

def btc_fiat(redis, fiat)
  key = "USD_#{fiat}"
  usd_fiat = BigDecimal.new(redis.get(key))
  btc_usd = 1 / BigDecimal.new(redis.get('USD_BTC'))
  return (btc_usd * usd_fiat)
end


redis = Redis.new

# crypto/crypto == DASH/XMR
dash_btc = 1 / BigDecimal.new(redis.get('BTC_DASH'))
btc_xmr  = BigDecimal.new(redis.get('BTC_XMR'))
dash_xmr = (dash_btc * btc_xmr)
puts "dash_xmr = [#{dash_xmr.ep}] (one DASH == this many XMR)"

# crypto/crypto == DASH/LTC
dash_btc = 1 / BigDecimal.new(redis.get('BTC_DASH'))
btc_ltc  = BigDecimal.new(redis.get('BTC_LTC'))
dash_ltc = (dash_btc * btc_ltc)
puts "dash_ltc = [#{dash_ltc.ep}] (one DASH == this many LTC)"

# crypto/fiat == DASH/EUR
dash_btc = 1 / BigDecimal.new(redis.get('BTC_DASH'))
btc_eur  = btc_fiat(redis, 'EUR')
puts "btc_eur = [#{btc_eur.ep}]"
dash_eur = (dash_btc * btc_eur)
puts "dash_eur = [#{dash_eur.ep}] (one DASH == this many EUR)"

# crypto/fiat == DASH/AUD
dash_btc = 1 / BigDecimal.new(redis.get('BTC_DASH'))
btc_aud  = btc_fiat(redis, 'AUD')
puts "btc_aud = [#{btc_aud.ep}]"
dash_aud = (dash_btc * btc_aud)
puts "dash_aud = [#{dash_aud.ep}] (one DASH == this many AUD)"

# crypto/fiat == DASH/USD
dash_btc = 1 / BigDecimal.new(redis.get('BTC_DASH'))
btc_usd  = btc_fiat(redis, 'USD')
puts "btc_usd = [#{btc_usd.ep}]"
dash_usd = (dash_btc * btc_usd)
puts "dash_usd = [#{dash_usd.ep}] (one DASH == this many USD)"

# crypto/crypto == DASH/BTC
dash_btc = 1 / BigDecimal.new(redis.get('BTC_DASH'))
btc_btc  = BigDecimal.new(redis.get('BTC_BTC'))
dash_btc = (dash_btc * btc_btc)
puts "dash_btc = [#{dash_btc.ep}] (one DASH == this many BTC)"

# crypto/fiat == LTC/EUR
ltc_btc = 1 / BigDecimal.new(redis.get('BTC_LTC'))
btc_eur  = btc_fiat(redis, 'EUR')
puts "btc_eur = [#{btc_eur.ep}]"
ltc_eur = (ltc_btc * btc_eur)
puts "ltc_eur = [#{ltc_eur.ep}] (one LTC == this many EUR)"

