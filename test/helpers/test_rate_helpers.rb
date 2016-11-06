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
    assert_equal '704.482500132', btc_fiat(@redis, 'USD').ep(12)
    assert_equal '632.09692324', btc_fiat(@redis, 'EUR').ep
    assert_equal '917.94985594', btc_fiat(@redis, 'AUD').ep
    assert_equal '5463.64643597', btc_fiat(@redis, 'HKD').ep
    assert_equal '944.20450976', btc_fiat(@redis, 'CAD').ep
    assert_equal '974.5078245', btc_fiat(@redis, 'SGD').ep
    assert_equal '562.76527799', btc_fiat(@redis, 'GBP').ep
  end

  def test_usd_crypto
    assert_equal '0.001419481676', usd_crypto(@redis, 'BTC').ep(12)
    assert_equal '0.10721015', usd_crypto(@redis, 'DASH').ep
    assert_equal '0.09061422', usd_crypto(@redis, 'ETH').ep
    assert_equal '0.25746265', usd_crypto(@redis, 'LTC').ep
    assert_equal '0.19880696', usd_crypto(@redis, 'XMR').ep
    assert_equal '12.75250809', usd_crypto(@redis, 'MAID').ep
    assert_equal '4435.8802375', usd_crypto(@redis, 'DOGE').ep
    assert_equal '0.48317188', usd_crypto(@redis, 'FCT').ep
  end

  def test_usd_fiat
    assert_equal '1.0', usd_fiat(@redis, 'USD').ep
    assert_equal '1.340281', usd_fiat(@redis, 'CAD').ep
    assert_equal '1.303013', usd_fiat(@redis, 'AUD').ep
    assert_equal '1.364488', usd_fiat(@redis, 'NZD').ep
    assert_equal '0.798835', usd_fiat(@redis, 'GBP').ep
    assert_equal '7.755546', usd_fiat(@redis, 'HKD').ep
    assert_equal '1.383296', usd_fiat(@redis, 'SGD').ep
    assert_equal '0.89725', usd_fiat(@redis, 'EUR').ep
  end

  def test_btc_crypto
    assert_equal '1.0', btc_crypto(@redis, 'BTC').ep(12)
    assert_equal '75.527674095', btc_crypto(@redis, 'DASH').ep(12)
    assert_equal '181.37792812', btc_crypto(@redis, 'LTC').ep(12)
    assert_equal '140.056022409', btc_crypto(@redis, 'XMR').ep(12)
    assert_equal '3125000.0', btc_crypto(@redis, 'DOGE').ep(12)
    assert_equal '340.38613403', btc_crypto(@redis, 'FCT').ep(12)
    assert_equal '8983.918785374', btc_crypto(@redis, 'MAID').ep(12)
    assert_equal '63.836130101', btc_crypto(@redis, 'ETH').ep(12)
  end

  def test_get_rate
    assert_equal '704.482500132', get_rate(@redis, 'BTC', 'USD').ep(12)
    assert_equal '0.001419481676', get_rate(@redis, 'USD', 'BTC').ep(12)

    assert_equal '1.854366946781', get_rate(@redis, 'DASH', 'XMR').ep(12)
    assert_equal '0.539267593038', get_rate(@redis, 'XMR', 'DASH').ep(12)

    assert_equal '2.401476416338', get_rate(@redis, 'DASH', 'LTC').ep(12)
    assert_equal '0.416410501972', get_rate(@redis, 'LTC', 'DASH').ep(12)

    assert_equal '8.369077041197', get_rate(@redis, 'DASH', 'EUR').ep(12)
    assert_equal '0.119487488846', get_rate(@redis, 'EUR', 'DASH').ep(12)

    assert_equal '12.15382132369', get_rate(@redis, 'DASH', 'AUD').ep(12)
    assert_equal '0.082278649107', get_rate(@redis, 'AUD', 'DASH').ep(12)

    assert_equal '9.327475108606', get_rate(@redis, 'DASH', 'USD').ep(12)
    assert_equal '0.107210149409', get_rate(@redis, 'USD', 'DASH').ep(12)

    assert_equal '0.01324018', get_rate(@redis, 'DASH', 'BTC').ep(12)
    assert_equal '75.527674095', get_rate(@redis, 'BTC', 'DASH').ep(12)

    assert_equal '3.484971571763', get_rate(@redis, 'LTC', 'EUR').ep(12)
    assert_equal '0.286946386511', get_rate(@redis, 'EUR', 'LTC').ep(12)

    assert_equal '0.00105909259', get_rate(@redis, 'CAD', 'BTC').ep(12)
    assert_equal '944.204509759417', get_rate(@redis, 'BTC', 'CAD').ep(12)

    assert_equal '0.746112195875', get_rate(@redis, 'CAD', 'USD').ep(12)
    assert_equal '1.340281', get_rate(@redis, 'USD', 'CAD').ep(12)

    assert_equal '0.972193890684', get_rate(@redis, 'CAD', 'AUD').ep(12)
    assert_equal '1.028601403056', get_rate(@redis, 'AUD', 'CAD').ep(12)

    assert_equal '0.596020535992', get_rate(@redis, 'CAD', 'GBP').ep(12)
    assert_equal '1.677794538034', get_rate(@redis, 'GBP', 'CAD').ep(12)

    assert_equal '1.6311415997', get_rate(@redis, 'GBP', 'AUD').ep(12)
    assert_equal '0.613067559572', get_rate(@redis, 'AUD', 'GBP').ep(12)

    assert_equal '0.954946470764', get_rate(@redis, 'NZD', 'AUD').ep(12)
    assert_equal '1.047179114867', get_rate(@redis, 'AUD', 'NZD').ep(12)
  end

end
