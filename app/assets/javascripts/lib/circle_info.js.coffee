
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
    if @$("input.login").length  > 0
      new TypeaheadExtension({
        el: @$("input.login"),
        source: "/search/users",
        field: "login",
        highlighter: (item) ->
          "<img class='photo' src='#{item.icon_url}' />#{item.login}"
      })

class root.CircleInfoView extends Backbone.View

  events:
    "click .shared" : "share_circle"
    "click .circle" : "select_circle"

  initialize: () ->
    @circle_id = @options.circle_id
    new InviteUserView(
      el: @$(".dialog-invite"),
      circle_id:@circle_id)

  state: () ->
    if @$(".selected").length > 0
      @$(".shared").removeClass("disabled")
    else
      @$(".shared").addClass("disabled")

  select_circle: (e) ->
    target = $(e.currentTarget)
    if target.hasClass("selected")
      target.removeClass("selected")
    else
      target.addClass("selected")
    @state()

  data: () ->
    ids = []
    if @$(".selected").length > 0
      els = @$(".selected") 
      _.each els, (el) =>
        ids.push($(el).attr("data-value-id"))
      return ids
    else
      return false

  share_circle: () ->
    return false if @$(".disabled").length == 1
    ids = @data()
    $.ajax(
      data: {ids: ids}
      url: "/communities/#{ @circle_id}/circles/share_circle"
      type: "post"
      success: () ->
        pnotify(text: '分享该圈子成功！!')
        $("#SelectCircle").modal('hide')
      error: (messages) ->
        pnotify(text: messages.responseText, type: "error")
    )

  render: () ->




