#author: huxinghai
#describe: 评论

root = window || @

class Comment extends Backbone.View
    comment_type: null

    login: null

    all: (targeable_id, limit, callback = ->)->
        if @comment_type?
            $.get @root_url(),{ targeable_type: @comment_type, targeable_id: targeable_id, limit: limit}, callback
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
        $.post("#{@root_url()}/#{@switch_action()}", params, $.proxy(callback, @), "json")



class CommentActivity extends Comment
    comment_type: "Activity"


class CommentProduct extends Comment
    comment_type: "Product"


root.CommentActivity = CommentActivity
root.CommentProduct = CommentProduct
