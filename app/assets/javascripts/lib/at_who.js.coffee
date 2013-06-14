# author : zhouxianfeng
# describe : 通过'@'获取用户
#= require jquery
#= require backbone
#= require lib/jquery.atwho

root = (window || @)

class AtWho extends Backbone.View

  initialize : (options) ->
    _.extend(@, options)
    @bind_atwho()

  bind_atwho : () ->
    @$("textarea").atwho('@', {
      search_key: "login"
      data: "/users",
      limit: 7,
      tpl: "<li data-value='${login}'>${login}</li>"
    })

window.AtWho = AtWho

