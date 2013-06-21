require "redis"
require "redis-namespace"
require "redis-search"
redis = Redis.new(:host => "127.0.0.1",:port => "6379")
redis.select(3)
# don't forget change the namespace
redis = Redis::Namespace.new("panama:redis_search", :redis => redis)
Redis::Search.configure do |config|
  config.redis = redis
  config.complete_max_length = 30
  config.pinyin_match = true
end

begin
  Product.new
rescue Exception => e
  false
end
