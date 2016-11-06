require File.expand_path('../../test_helper', __FILE__)
require 'rate_helpers'

class TestRateHelpers < Minitest::Test
  include RateHelpers
  attr_reader :fiat_tickers, :crypto_tickers

  private def load_fixtures
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
      inst = klass.new($redis)
      inst.load(inst.post_process(File.read(absfile)))
    end
  end


  def setup
    $redis.flushall
    load_fixtures

    @fiat_tickers = %w[ CNY USD CAD ZAR HKD ]
    @crypto_tickers = %w[ BTC LTC DASH XMR MAID ETH ]
  end

  def test_is_fiat
    @fiat_tickers.each do |ticker|
      assert is_fiat(ticker)
    end

    @crypto_tickers.each do |ticker|
      assert !is_fiat(ticker)
    end
  end

  def test_is_crypto
    @crypto_tickers.each do |ticker|
      assert is_crypto(ticker)
    end

    @fiat_tickers.each do |ticker|
      assert !is_crypto(ticker)
    end
  end
end


