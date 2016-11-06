require File.expand_path('../../test_helper', __FILE__)
require 'rate_helpers'

class ::BigDecimal
  # "easy print"
  def ep(num=8)
    round(num).to_s("#{num}F")
  end
end

class TestRateHelpers < Minitest::Test
  include RateHelpers
  attr_reader :fiat_tickers, :crypto_tickers

  private def load_fixtures(redis)
    fixture_dir = '../fixture-data'
    klasses = [
      {
        klass: BitcoinAverageAPI,
         file: 'ba2_global_all.json'
      },
      {
        klass: PoloniexAPI,
         file: 'polo.json'
      },
    ]
    klasses.each do |h|
      klass = h[:klass]
      fn = h[:file]
      absfile = File.expand_path(File.join(fixture_dir, fn), __dir__)
      inst = klass.new(redis)
      inst.load(inst.post_process(File.read(absfile)))
    end
  end


  def setup
    @redis = $redis
    @redis.flushall
    load_fixtures(@redis)

    @fiat_tickers = %w[ CNY USD CAD ZAR HKD ]
    @crypto_tickers = %w[ BTC LTC DASH XMR MAID ETH ]
  end

  def test_is_fiat
    @fiat_tickers.each do |ticker|
      assert is_fiat(@redis, ticker)
    end

    @crypto_tickers.each do |ticker|
      assert !is_fiat(@redis, ticker)
    end
  end

  def test_is_crypto
    @crypto_tickers.each do |ticker|
      assert is_crypto(@redis, ticker)
    end

    @fiat_tickers.each do |ticker|
      assert !is_crypto(@redis, ticker)
    end
  end

  def test_btc_fiat
    assert_equal '704.48250013', btc_fiat(@redis, 'USD').ep
    assert_equal '632.09692324', btc_fiat(@redis, 'EUR').ep
    assert_equal '917.94985594', btc_fiat(@redis, 'AUD').ep
    assert_equal '5463.64643597', btc_fiat(@redis, 'HKD').ep
    assert_equal '944.20450976', btc_fiat(@redis, 'CAD').ep
    assert_equal '974.5078245', btc_fiat(@redis, 'SGD').ep
    assert_equal '562.76527799', btc_fiat(@redis, 'GBP').ep
  end

  def test_usd_crypto
    assert_equal '0.001419481676', usd_crypto(@redis, 'BTC').ep(12)
    assert_equal '0.19880696', usd_crypto(@redis, 'XMR').ep
    assert_equal '0.10721015', usd_crypto(@redis, 'DASH').ep
    assert_equal '0.09061422', usd_crypto(@redis, 'ETH').ep
    assert_equal '0.25746265', usd_crypto(@redis, 'LTC').ep
    assert_equal '12.75250809', usd_crypto(@redis, 'MAID').ep
    assert_equal '4435.8802375', usd_crypto(@redis, 'DOGE').ep
    assert_equal '0.48317188', usd_crypto(@redis, 'FCT').ep
  end


end
