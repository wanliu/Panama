
root  = window || @

class  NotificationView extends Backbone.View

  initialize: () ->
    _.extend(@, @options)
    @collection_count = 0
    @urlRoot = "/people/#{@current_user_login}/notifications"
    @collection = new Backbone.Collection()
    @transactions_contain_view = new TransactionContainer(parent_view: @)
    @activitys_contain_view = new ActivityContainer(parent_view: @, login: @current_user_login)
    @collection.bind('reset', @add_all, @)
    @fetch()

  add_all: () ->
    @$count = $("#notification_count")
    if @collection_count <= 0
      @$count.remove()
    else
      @$count.text(@collection_count)

    @collection.each (model) =>
      info = model.attributes
      if model.attributes.targeable_type == "Activity"
        @activitys_contain_view.collection.add(model)
      else
        @transactions_contain_view.collection.add(model)

    @add_more()

  add_more: () ->
    if @collection_count > 10
      $(".notifications", @$el).append("<li><a href='#{@urlRoot}'>更多</a></li>")

  fetch_data: (count) ->
    @collection_count = count
    @collection.fetch(data: {limit: 10, offset: 0}, url: "#{@urlRoot}/unreads")

  fetch: () ->
    $.ajax(
      url: "#{@urlRoot}/unread_count",
      dataType: "json"
      success: (data) =>
        @fetch_data(data.count)
    )

class TransactionContainer extends Backbone.View

  initialize: () ->
    el = @options.parent_view.el
    @collection = new Backbone.Collection()
    @collection.bind('add', @add_one, @)

  add_one: (model) ->
    @transactions_view = new TransactionView({
      parent_el: @,
      model: model.attributes
    })
    $(@options.parent_view.el).find(".notifications").append(@transactions_view.render(model.toJSON()))


class TransactionView extends Backbone.View
  tagName: "li"
  className: "transactions_li"

  events:
    "click" : "direct_to_transaction_detail"

  template:
    "<a href='{{ url }}'>
      <span class='label label-warning'><i class='icon-info-sign'></i></span>
      {{ body }}
    </a>"

  render: (model) ->
    $(@el).html(Hogan.compile(@template).render(model))

  direct_to_transaction_detail: () ->
    url = @options.parent_el.options.parent_view.urlRoot
    $.ajax({
      type: "POST",
      dataType: "json",
      url: "#{ url }/#{ @model.id }/mark_as_read",
      success: () =>
        window.location.replace(@model.get('url'))
    })


class ActivityContainer extends Backbone.View

  initialize: () ->
    @el = @options.parent_view.el
    @collection = new Backbone.Collection()
    @collection.bind('add', @add_one, @)

  add_one: (model) ->
    @transactions_view = new ActivityViews({
      model: model.attributes,
      parent_view: @,
      login: @login
    })
    $(@el).find(".notifications").append(@transactions_view.render(model.toJSON()))

  remove_one: (id, el) ->
    model = @collection.get(id)
    @collection.remove model if model?
    $("#notification_count").html($("#notification_count").text() - 1)
    el.remove()


class ActivityViews extends Backbone.View
  tagName: "li"
  className: "activitys_li"

  events:
    "click " : "show_modal"

  template:
    "<a href='#'>
      <span class='label label-success'><i class='icon-bell-alt'></i></span>
      {{ body }}
    </a>"

  initialize: () ->
    _.extend(@, @options)

  show_modal: () ->
    activity_model = new ActivityModel({
      id: @model.targeable_id
    })

    activity_model.fetch success: (model) =>
      new ActivityView({
        model: model,
        el: $("#popup-layout"),
        login: @login
      }).modal()
    @remove()
    false

  render: (model) ->
    $(@el).html(Hogan.compile(@template).render(model))

  remove: () ->
    url = @parent_view.options.parent_view.urlRoot
    $.ajax(
      type: "POST",
      dataType: "json",
      url: "#{ url }/#{ @model.id }/mark_as_read",
      success: () =>
        @parent_view.remove_one(@model.id,@el)
    )


root.NotificationView = NotificationView