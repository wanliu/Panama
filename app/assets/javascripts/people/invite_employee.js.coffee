#description: 邀请雇员

root = (window || @)

class root.InviteEmployee extends Backbone.View
  events: {
    "submit form.invite" : 'agree'
    "click .refuse" : "refuse"
  }
  initialize: () ->
    _.extend(@, @options)

  agree: () ->
    $.ajax(
      url: @agree_url,
      type: "POST",
      dataType: "JSON",
      success: (data) =>
        pnotify(text: "成功加入该企业！")
        window.location.href = "/shops/#{data.targeable.name}/admins"
      error: (xhr) =>
        @pnotify_error(xhr.responseText)
    )
    false

  refuse: () ->
    $.ajax(
      url: @refuse_url,
      type: "POST",
      dataType: "JSON",
      success: (data) =>
        window.location.href = "/people/#{data.user.login}/notifications"
      error: () =>      
        @pnotify_error(xhr.responseText)
    )

  pnotify_error: (text) ->
    try
      ms = JSON.parse(text).join("<br />")
      pnotify(text: ms, type: 'error')
    catch error
      pnotify(text: text, type: 'error')


