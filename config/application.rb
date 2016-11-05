ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

$:.push('lib')
$:.push('lib/workers')
require 'bitcoin_average_worker'
require 'poloniex_worker'
