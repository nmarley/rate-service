require 'test_helper'
require 'minitest/autorun'
require 'rate_helpers'

class TestRateHelpers < Minitest::Test
  include RateHelpers
  attr_reader :fiat_tickers, :crypto_tickers

  def setup
    $redis = Redis.new
    # $redis.flushall  # once using redis-namespace...

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


