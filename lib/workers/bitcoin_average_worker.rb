require 'sidekiq'
require 'rate_source'

class BitcoinAverageWorker
  include Sidekiq::Worker

  def perform
    redis = Redis.new
    BitcoinAverageAPI.new(redis).fetch_and_load
  end
end
