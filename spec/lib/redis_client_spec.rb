#encoding: utf-8
require "spec_helper"

describe RedisClient, "redis 客户端" do

  it "连接服务器" do
    RedisClient.should respond_to :redis
  end
end