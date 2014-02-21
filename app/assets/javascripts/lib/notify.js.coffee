#!= require lib/jquery.pnotify
#!= require lib/jquery.gritter
#= require noty/jquery.noty
#= require noty/layouts/top
#= require noty/layouts/topRight
#= require noty/themes/default
#= require noty/themes/notify
# 系统提醒
#
# $.notifier({
#  avatar: "http://localhost:3000/avatar.jpg",
#  title: "聊天提醒"
#  text: "某某给你留言"}) 桌面通知
#
# pnotify 站点通知

$.noty.defaults.layout = 'topRight';


class Notifier
  stack_options:
    stack_topleft: {
      "dir1": "down",
      "dir2": "right",
      "push": "top"
    },
    stack_bottomleft: {
      "dir1": "right",
      "dir2": "up",
      "push": "top"
    },
    stack_custom: {
      "dir1": "right",
      "dir2": "down"
    },
    stack_custom2: {
      "dir1": "left",
      "dir2": "up",
      "push": "top"
    },
    stack_bar_top: {
      "dir1": "down",
      "dir2": "right",
      "push": "top",
      "spacing1": 0,
      "spacing2": 0
    },
    stack_bar_bottom: {
      "dir1": "up",
      "dir2": "right",
      "spacing1": 0,
      "spacing2": 0
    },
    stack_bottomright: {
      "dir1": "up",
      "dir2": "left",
      "firstpos1": 25,
      "firstpos2": 25
    },
    stack_topright: {
      "dir1": "down",
      "dir2": "left",
      "push": "top"
    }

  default_options: {
    timeout: 8000,
    title: "系统提醒",
    text: "",
    type: "success",
    avatar: "http://panama.b0.upaiyun.com/default_avatar.jpg!50x50"
  },

  constructor: () ->

  setPermission: () ->
    if @support_browser()
      unless @has_avaliable()
        el = @pnotify(
          addclass: "stack-bottomright",
          stack: "stack_bottomright",
          title: "系统提示",
          text: "<a href='javascript:void(0)' id='agree_notifiction_desktop'>点击这里</a>开启桌面提醒功能！")

        $(el.$message).on "click", "#agree_notifiction_desktop", (e) ->
          $(this).parents("li").remove()
          e.preventDefault()
          window.webkitNotifications.requestPermission(() ->
            console.log("allow permission?")
          )

  support_browser: () ->
    if (window.webkitNotifications || navigator.mozNotification) then true else false

  has_avaliable: () ->
    window.webkitNotifications.checkPermission() == 0

  visitUrl: (url) ->
    window.location.href = url

  notify: (options = {}) ->
    _options = $.extend({}, @default_options, options)
    if @support_browser()
      if @has_avaliable()
        peup = window.webkitNotifications.createNotification(_options.avatar, _options.title, _options.text)
        if _options.hasOwnProperty("url")
          peup.onclick = () ->
            window.parent.focus()
            notifier.visitUrl(options.url)
            peup.cancel()

        peup.show()
        if _options.hasOwnProperty("delay")
          setTimeout(() ->
            peup.cancel() if peup.cancel
          ,_options.delay)
        return

    @pnotify(_options)

  pnotify: (options) ->
    # if options.hasOwnProperty("stack")
    #   options["stack"] = @stack_options[options.stack]
    # if options.hasOwnProperty("avatar")
      # options["text"] = "<img class='avatar' src='#{options["avatar"]}' alt='头像'/>#{options["text"]}"
      # options['text_escape'] = false

    # options.styling = "bootstrap"
    # $.gritter.add options
    noty(options)
    # $.pnotify options

window.notifier = new Notifier()
window.pnotify = notifier.pnotify
jQuery.notifier = (options) ->
  notifier.notify(options)