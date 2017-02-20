require File.expand_path('../config/application', __dir__)
require_relative 'rate_source'

module RateService
  class << self
    def ingest
      BitcoinAverageAPI.new($redis).fetch_and_load
      PoloniexAPI.new($redis).fetch_and_load
    end
  end
end
