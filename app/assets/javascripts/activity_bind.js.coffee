root = window || @

class ActivityBind extends Backbone.View

  events:
    "click .like-button"            : "like"
    "click .unlike-button"          : "unlike"
    "click .auction .partic-button" : 'addToCard'
    "click .submit-comment"         : "addComment"
    "keyup textarea[name=message]"  : 'filter_state'
    'submit form.new_product_item'  : 'join'
    "click .focus .partic-button"   : "joinFocus"
    "click .focus .unpartic-button" : "unjoinFocus"
    "click .circle"                 : "select_circle"
    "click .share_activity"         : "share_activity"

  like_template: '<a class="btn like-button" href="#"><i class="icon-heart"></i> 喜欢</a>'
  unlike_template: '<a class="btn unlike-button active" href="#"> 取消喜欢</a>'
  unpartic_template: '<button class="btn btn-danger unpartic-button" type="submit" name="unjoin"> 取消参与</button>'
  partic_template: '<button class="btn btn-danger partic-button active" type="submit" name="join"><i class="icon-shopping-cart icon-white"></i> 参与</button>'

  like: (event) ->
    $.post(@model.url() + "/like", (data) =>
      @like_view = new LikeListView()
      @like_view.add_to_cart(data)
      @$('.like-button').replaceWith(@unlike_template)
      @$('.like-count').addClass("active")
      @incLike()
    )
    false

  unlike: (event) ->
    $.post(@model.url() + "/unlike", (data) =>
      @like_view = new LikeListView()
      @like_view.move_from_cart(data)
      @$('.unlike-button').replaceWith(@like_template)
      @$('.like-count').removeClass("active")
      @decLike()
    )
    false

  incLike: (n = 1) ->
    s = parseInt(@$('.like-count').text()) || 0
    @$('.like-count').text(s + n)

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
      success: (data) =>
        comment_template = _.template($('#comment-template').html())
        @$(".comments").append(comment_template(comment))
        @$(".comments>.comment").last().slideDown("slow")
        @$("textarea",".message").val("")
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

  state: () ->
    if @$(".selected").length > 0
      @$(".share_activity").removeClass("disabled")
    else
      @$(".share_activity").addClass("disabled")

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

  share_activity: () ->
    return false if $(".share_activity_to_circles .disabled").length == 1
    @$(".share_activity").addClass('disabled')
    ids = @data()
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
    new ActivityBuyView({activity_id: @model.id})
    false

root.ActivityBind = ActivityBind