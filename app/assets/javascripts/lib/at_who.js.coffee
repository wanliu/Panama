# author : zhouxianfeng
# describe : 通过'@'获取用户

define(["jquery", "backbone", "lib/jquery.atwho"], ($, Backbone, atwho) ->

    class AtWho extends Backbone.View

        initialize : (options) ->
            _.extend(@, options)
            @names = []
            @all_user((data, xhr) =>
                    _.each(data,(d) =>
                        @names.push(d["user"]["login"])
                    )
                    @bind_atwho(@names)
                )
            # @bind_atwho(@names)


        all_user : (callback = ->) ->
            $.get("/users", callback)


        bind_atwho : (names) ->
            @$("textarea").atwho('@', {
                data: names
                # data: "http://localhost:3000/users",
                # callback: {
                #     remote_filter: (params, url, render_view) -> 
                #         debugger
                # }
            })

    AtWho
)