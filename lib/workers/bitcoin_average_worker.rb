require 'sidekiq'
require 'rate_source'
require File.expand_path('../../config/init', __dir__)

class BitcoinAverageWorker
  include Sidekiq::Worker

  def perform
    BitcoinAverageAPI.new($redis).fetch_and_load
  end
end
