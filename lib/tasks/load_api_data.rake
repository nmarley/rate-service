require File.expand_path('../../config/application', __dir__)

namespace :redis do
  desc "Populate Redis cache with price ticker data"
  task :populate do
    redis = Redis.new
    BitcoinAverageAPI.new(redis).fetch_and_load
    PoloniexAPI.new(redis).fetch_and_load
  end
end

