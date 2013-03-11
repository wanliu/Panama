# author : zhouxianfeng
# describe : 通过'@'获取用户

define(["jquery", "backbone", "lib/jquery.atwho"], ($, Backbone, atwho) ->

    class AtWho extends Backbone.View

        initialize : (options) ->
            _.extend(@, options)
            @all_user((data, xhr) =>
                    # @bind_atwho(data)
                )
            @bind_atwho()


        all_user : (callback = ->) ->
            $.get("/users", callback)


        bind_atwho : (names) ->
            
            @$("textarea").atwho('@', {
                name: "users"
                data: "http://localhost:3000/users",
                limit: 7
                # data: names
                # data: "http://localhost:3000/users",
                # callback: {
                #     remote_filter: (params, url, render_view) -> 
                #         debugger
                # }
            })

    AtWho
)