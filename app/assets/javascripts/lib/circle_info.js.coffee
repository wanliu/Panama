
root = window || @

class InviteUserView extends Backbone.View
  events:
    "submit form" : "invite"

  initialize: () ->
    @circle_id = @options.circle_id
    @$form = @$("form")
    @$dialog = @$("dialog-invite")
    @search_user()

  render: () ->
    @$el

  invite: () ->
    data = @$form.serializeHash()

    if _.isEmpty(data.login)
      @$(".user").addClass("error")
      return false

    $.ajax(
      url: "/communities/#{@circle_id}/invite"
      type: "POST"
      dataType: "json"
      data: {invite: data}
      success: (data) =>
        @$("input.login").val("")
        @$("textarea.body").val("")
        pnotify(text: '邀请对方成功, 等待对方同意!')

      error: (messages) ->
        try
          ms = JSON.parse(messages.responseText)
          pnotify(text: ms.join("<br />"), type: "error")
        catch e
          pnotify(text: messages.responseText, type: "error")
    )

    return false

  search_user: () ->
    new TypeaheadExtension({
      el: @$("input.login"),
      source: "/search/users",
      field: "login",
      highlighter: (item) ->
        "<img class='photo' src='#{item.icon_url}' />#{item.login}"
    })

class root.CircleInfoView extends Backbone.View

  initialize: () ->
    @circle_id = @options.circle_id
    new InviteUserView(
      el: @$(".dialog-invite"),
      circle_id:@circle_id)

  render: () ->



