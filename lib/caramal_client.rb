require 'bunny'
require 'json'

module CaramalClient
  MQ_PREFIX = 'wanliu_'
  # public publish
  # login: String 用户名
  # channel: 频道名
  # msg:  消息， 消息格式 Hash
  # 例子:
  #     require 'caramal_client'
  #
  #     CaramalClient.publish('hysios', '/transcations', {:id => 1234 })
  def publish(login, channel, msg)
    info = {
      login: login,
      channel: channel,
      msg: msg
    }

    conn = Bunny.new(:hostname => "localhost")
    conn.start

    ch = conn.create_channel

    ch.default_exchange.publish info.to_json, :routing_key => MQ_PREFIX + 'notification'

    conn.close

  end
end