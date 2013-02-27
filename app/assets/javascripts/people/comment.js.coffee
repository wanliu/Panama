#author: huxinghai
#describe: 评论

define(["jquery", "backbone", "exports"], -> ($, Backbone, exports)

    class Comment extends Backbone.View
        comment_type: null

        login: null

        all: (callback = ->)->
            if @comment_type?
                $.get @root_url(), comment_type: @comment_type, callback
            else
                console.error("请设置comment type!")

        root_url: () ->
            if @login?
                "/people/#{@login}/comments"
            else
                console.error("没有登陆!")

        switch_action: () ->
            switch @comment_type
                when "Activity" then "activity"
                when "Product" then "product"
                else console.error("没有comment typea action")

        send_comment: (params, callback = ->) ->
            $.post("#{@root_url()}/#{@switch_action()}", params, callback)

        renderNew: (callback = ->) ->
            $.get("#{@root_url()}/new", null, callback)


    class CommentActivity extends Comment
        comment_type: "Activity"


    class CommentProduct extends Comment
        comment_type: "Product"


    exports.CommentActivity = CommentActivity
    exports.CommentProduct = CommentProduct
    exports
)