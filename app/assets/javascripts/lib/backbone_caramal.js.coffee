

class ChatView extends Caramal.BackboneView


class Caramal.BackboneView extends Backbone.View

  default_driver: Caramal.Chat

  PROXY_METHODS: [
    'onMessage',
    'onEvent',
    'open',
    'join',
    'send'
  ]

  constructor: (@user) ->

    @proxyMethods()

  proxyMethods: () ->

    for name in PROXY_METHODS

      if _.isFunction(@[name])
        throw new Error('always have this named method of ' + name);
      else
        @[name] = (args...) =>
          unless @channel?
            @channel = Caramal.MessageManager.nameOfChannel(@user) or
              @default_driver.create(@user)

          @channel[name].apply(@channel, args)



