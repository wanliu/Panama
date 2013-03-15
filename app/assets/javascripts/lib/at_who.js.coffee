# author : zhouxianfeng
# describe : 通过'@'获取用户

define(["jquery", "backbone", "lib/jquery.atwho"], ($, Backbone, atwho) ->

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
    AtWho
)