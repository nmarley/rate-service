ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

$:.push('lib')
$:.push('app/workers')

#require File.expand_path('../../config/application', __file__)
require './config/application'
require 'bitcoin_average_worker'
require 'poloniex_worker'

namespace :redis do
  desc "Populate Redis cache with price ticker data"
  task :populate do
    redis = Redis.new
    BitcoinAverageAPI.new(redis).fetch_and_load
    PoloniexAPI.new(redis).fetch_and_load
  end
end

