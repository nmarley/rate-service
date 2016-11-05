# test_helper.rb
ENV['RACK_ENV'] ||= 'test'
require 'minitest/autorun'

require File.expand_path('../config/application', __dir__)
