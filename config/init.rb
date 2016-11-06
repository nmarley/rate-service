require 'redis'
require 'redis-namespace'

ns = ENV.fetch('RACK_ENV', nil)
$redis = Redis::Namespace.new(ns, redis: Redis.new)
