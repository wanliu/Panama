
root  = window || @

class root.ApplyJoinCircle extends Backbone.View

  events:
    "click"  : "apply_join_circle"

  apply_join_circle: () ->
    $.ajax({
      dataType: "json",
      type: "post",
      data:{ id: @model.id},
      url: "/people/#{@options.current_user_login}/circles/apply_join",
      success: (notice) =>
        pnotify({text: notice.message })
        if notice.type == "waiting"
          $(@el).replaceWith("<span class='label-warning waiting'>等待确认</span>")
        else
          $(@el).replaceWith("<span class='label label-warning be_in'>已加入</span>")
      error: (notice)=>
        message = JSON.parse(notice.responseText).message
        pnotify({text: message })
    })

class QuitCircle extends Backbone.View
  events: 
    "click" : "quit_circle"

  quit_circle: (event) ->
    return unless confirm('确定退出商圈吗？')
    $.ajax({
      type: "delete",
      url: "/communities/#{@options.circle_id}/circles/quit_circle",
      success: (data, xhr, res) =>
        window.location.href = "/people/#{@options.current_user_login}/communities"
    })

class ApplyJoinCircleList extends Backbone.View
  initialize: () ->
    _.extend(@, @options)
    els1 = @$(".add_circle")
    _.each els1, (el) =>
      new ApplyJoinCircle({
        el: el,
        model: {id: $(el).attr("data-value-id")},
        current_user_login: @current_user_login,
      })

    els2 = @$(".quit_circle")
    _.each els2, (el) =>
      new QuitCircle({
        el: el,
        circle_id: $(el).attr("data-value-id"),
        current_user_login: @current_user_login,
      })


root.ApplyJoinCircleList = ApplyJoinCircleList