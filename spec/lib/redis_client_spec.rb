#encoding: utf-8
require "spec_helper"

describe RedisClient, "redis 客户端" do

  it "连接服务器" do
    config = YAML::load_file("config/application.yml")[Rails.env]
    Redis.should_receive(:new).with(:host => config["redis_server"], :port => config["redis_port"])
    RedisClient.redis
  end
end