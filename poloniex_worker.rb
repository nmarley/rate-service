require 'rate_source'

class PoloniexWorker
  include Sidekiq::Worker

  def perform
    redis = Redis.new
    PoloniexAPI.new(redis).fetch_and_load
  end
end
