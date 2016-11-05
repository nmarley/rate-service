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

def usd_crypto(redis, crypto)
  key = "BTC_#{crypto}"
  btc_crypto = BigDecimal.new(redis.get(key))
  usd_btc = BigDecimal.new(redis.get('USD_BTC'))
  return (usd_btc * btc_crypto)
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

# crypto/crypto == XMR/DASH
xmr_btc = 1 / BigDecimal.new(redis.get('BTC_XMR'))
btc_dash  = BigDecimal.new(redis.get('BTC_DASH'))
xmr_dash = (xmr_btc * btc_dash)
puts "xmr_dash = [#{xmr_dash.ep}] (one XMR == this many DASH)"

# fiat/fiat == GBP/AUD
gbp_usd = 1 / BigDecimal.new(redis.get('USD_GBP'))   # invert the base...
usd_aud = BigDecimal.new(redis.get('USD_AUD')) # do NOT invert the quote...
gbp_aud = (gbp_usd * usd_aud)
puts "gbp_aud = [#{gbp_aud.ep}] (one GBP == this many AUD)"

# fiat/fiat == GBP/CAD
gbp_usd = 1 / BigDecimal.new(redis.get('USD_GBP'))   # invert the base...
usd_cad = BigDecimal.new(redis.get('USD_CAD')) # do NOT invert the quote...
gbp_cad = (gbp_usd * usd_cad)
puts "gbp_cad = [#{gbp_cad.ep}] (one GBP == this many CAD)"

# fiat/fiat == CAD/AUD
cad_usd = 1 / BigDecimal.new(redis.get('USD_CAD'))   # invert the base...
usd_aud = BigDecimal.new(redis.get('USD_AUD')) # do NOT invert the quote...
cad_aud = (cad_usd * usd_aud)
puts "cad_aud = [#{cad_aud.ep}] (one CAD == this many AUD)"

# fiat/fiat == USD/CAD
usd_usd = 1 / BigDecimal.new(redis.get('USD_USD'))   # invert the base...
usd_cad = BigDecimal.new(redis.get('USD_CAD')) # do NOT invert the quote...
usd_cad = (usd_usd * usd_cad)
puts "usd_cad = [#{usd_cad.ep}] (one USD == this many CAD)"

# fiat/fiat == CAD/USD
cad_usd = 1 / BigDecimal.new(redis.get('USD_CAD'))   # invert the base...
usd_usd = BigDecimal.new(redis.get('USD_USD')) # do NOT invert the quote...
cad_usd = (cad_usd * usd_usd)
puts "cad_usd = [#{cad_usd.ep}] (one CAD == this many USD)"

# fiat/crypto == CAD/BTC
cad_usd = 1 / BigDecimal.new(redis.get('USD_CAD'))   # invert the base...
usd_btc = usd_crypto(redis, 'BTC')
puts "usd_btc = [#{usd_btc.ep}], inverted: [#{(1 / usd_btc).ep}]"
cad_btc = (cad_usd * usd_btc)
puts "cad_btc = [#{cad_btc.ep}] (one CAD == this many BTC)"

# fiat/crypto == EUR/DASH
eur_usd = 1 / BigDecimal.new(redis.get('USD_EUR'))   # invert the base...
usd_dash = usd_crypto(redis, 'DASH')
puts "usd_dash = [#{usd_dash.ep}], inverted: [#{(1 / usd_dash).ep}]"
eur_dash = (eur_usd * usd_dash)
puts "eur_dash = [#{eur_dash.ep}] (one EUR == this many DASH)"

