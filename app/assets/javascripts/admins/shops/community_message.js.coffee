
root = window || @

class root.CommunityApplyJoin extends Backbone.View
  events: 
    "click input.agree" : "agree"
    "click input.refuse": "refuse"

  agree: () ->
    $.ajax(
      url: @fetch_url("join_circle"),
      type: "POST",
      success: () ->
        pnotify({text: "加入成功！"})
      error: (xhr) ->
        m = JSON.parse(xhr.responseText)
        pnotify({text: m, type: "error"})
    )

  refuse: () ->
    $.ajax(
      url: @fetch_url("refuse_join"),
      type: "POST",
      success: () =>
        window.location.href = @options.remote_url
    )
    
  fetch_url: (method_name) ->
    "#{@options.remote_url}/#{method_name}/#{@options.cn_id}"