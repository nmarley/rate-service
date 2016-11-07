require 'sidekiq'
require 'rate_source'
require File.expand_path('../../config/init', __dir__)

class PoloniexWorker
  include Sidekiq::Worker

  def perform
    PoloniexAPI.new($redis).fetch_and_load
  end
end
