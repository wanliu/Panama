#encoding: utf-8
require "spec_helper"

describe FayeClient, "faye 客户端" do

  it "向服务器发送信息" do
    FayeClient.send("/channel", "发送信息")
  end
end