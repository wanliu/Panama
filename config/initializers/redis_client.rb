require "redis"

module RedisClient
  def self.redis
    config = YAML::load_file("config/application.yml")[Rails.env]
    @redis ||= Redis.new(:host => config["redis_server"], :port => config["redis_port"])
  end
end


