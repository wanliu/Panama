#= require chosen_tool
root = window || @

class ActivityBind extends Backbone.View

  events:
    "click .like-button"                 : "like"
    "click .unlike-button"               : "unlike"
    "click .auction .partic-button"      : 'addToCard'
    "click .submit-comment"              : "addComment"
    "keypress textarea[name=message]"    : "key_up"
    "keyup textarea[name=message]"       : 'filter_state'
    'submit form.new_product_item'       : 'join'
    "click .focus .partic-button"        : "joinFocus"
    "click .focus .unpartic-button"      : "unjoinFocus"
    # "click .circle"                      : "select_circle"
    "click .share_activity"              : "share_activity"

  like_template: '<a class="btn like-button" href="#"><i class="icon-heart"></i> 喜欢</a>'
  unlike_template: '<a class="btn unlike-button active" href="#"> 取消喜欢</a>'
  unpartic_template: '<button class="btn btn-danger unpartic-button" type="submit" name="unjoin"> 取消参与</button>'
  partic_template: '<button class="btn btn-danger partic-button active" type="submit" name="join"><i class="icon-shopping-cart icon-white"></i> 参与</button>'

  initialize: (options) ->
    _.extend(@, options)
    @tool = new chosenTool({
      el: $(@el)
    })

  like: (event) ->
    $btn = @$(".like-button")
    return false if $btn.hasClass("disabled") 
    $btn.addClass("disabled")
    $.post(@model.url() + "/like", (data) =>
      @like_view = new LikeListView()
      @like_view.add_to_cart(data)
      @$('.like-button').replaceWith(@unlike_template)
      @$('.like-count').addClass("active")
      @incLike()
    ).complete () -> $btn.removeClass("disabled")
    false

  unlike: (event) ->
    $btn = @$(".unlike-button")
    return false if $btn.hasClass("disabled") 
    $btn.addClass("disabled")
    $.post(@model.url() + "/unlike", (data) =>
      @like_view = new LikeListView()
      @like_view.move_from_cart(data)
      @$('.unlike-button').replaceWith(@like_template)
      @$('.like-count').removeClass("active")
      @decLike()
    ).complete () -> $btn.removeClass("disabled")
    false

  incLike: (n = 1) ->
    s = parseInt(@$('.like-count').text()) || 0
    @$('.like-count').text(s + n)

  key_up: (e) ->
    @addComment(e) if (e.keyCode == 10 || e.keyCode == 13) &&  e.ctrlKey == true

  decLike: (n = 1) ->
    s = parseInt(@$('.like-count').text()) || 0
    @$('.like-count').text(s - n)

  addComment: (event) ->
    content = @$("textarea",".message").val()
    return unless content.trim() != ""
    comment = {content: content, targeable_id: @model.id}
    $.ajax(
      url: '/comments/activity',
      data: {comment: comment}
      type: 'POST'
      dataType: "JSON"
      success: (data, xhr, res) =>
        data.created_at = new Date().format('yyyy-MM-dd hh:mm')
        comment_template = _.template($('#comment-template').html())
        @$(".comments").append(comment_template(data))
        @$(".comments>.comment").last().slideDown("slow")
        @$("textarea",".message").val("")
      error: (data, xhr, res) =>
        pnotify(type: 'error', text: "评论失败了～～～")
    )

  filter_state: () ->
    message = @$("textarea",".message").val().trim()
    comment = @$(".submit-comment")
    if _.isEmpty(message)
      comment.addClass("disabled")
    else
      comment.removeClass("disabled")

  validate_date: () ->
    values = @$("form.new_product_item").serializeArray()
    data = {}
    _.each values, (v) -> data[v.name] = v.value

    if parseFloat(data['product_item[amount]']) <= 0
      pnotify({text: "数量不能少于等于0"})
      return false

    unless /^\d+(\.?\d+)?$/.test(data['product_item[amount]'])
      pnotify({text: "请输入正确的数量！"})
      return false
    return data

  joinFocus: (event) ->
    $.post($("form", @el).attr("action"), (data) =>
      @$('.partic-button').replaceWith(@unpartic_template)
      @$('.like-count').addClass("active")
      pnotify({text: "成功参与聚焦活动！"})
      @incPartic()
      false
    )
    false

  unjoinFocus: (event) ->
    $.post($("form", @el).attr("action"), (data) =>
      @$('.unpartic-button').replaceWith(@partic_template)
      @$('.partic-count').removeClass("active")
      pnotify({text: "成功取消参与聚焦活动！"})
      @decPartic()
      false
    )
    false

  incPartic: (n = 1) ->
    s = parseInt(@$('.partic-count').text()) || 0
    @$('.partic-count').text(s + n)

  decPartic: (n = 1) ->
    s = parseInt(@$('.partic-count').text()) || 0
    @$('.partic-count').text(s - n)

  addToCard: (e) ->
    $target = $(e.currentTarget)
    [ $form, url ] = [ @$('.new_product_item'), $target.attr('add-to-action')]
    MyCart.myCart.addToCart(@$('.preview'),$form , url)
    false

  share_activity: () ->
    return false if $(".share_activity_to_circles .disabled").length == 1
    @$(".share_activity").addClass('disabled')
    ids = @tool.data()
    activity_id = @model.get('id')
    $.ajax(
      data: {ids: ids}
      url: "/activities/"+activity_id+"/share_activity"
      type: "post"
      success: () =>
        $(".share_activity_to_circles").modal('hide')
        pnotify(text: '分享活动成功！!')
      error: (messages) ->
        pnotify(text: messages.responseText, type: "error")
    )

  join: () ->
    amount = @$('form.new_product_item input[name="product_item[amount]"]').val()
    new ActivityBuyView({activity_id: @model.id, amount: amount})
    false

root.ActivityBind = ActivityBind