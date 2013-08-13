root = (window || @)

class ActivitiesContainerView extends ContainerView
  
  initialize: (options) ->
    _.extend(@, options)
    @bind_realtime()
    super

  bind_realtime: () ->
    @client = Realtime.client(@realtime_url)
    @client.subscribe "/Activity/un_dispose", (info) =>
      @realtime_help(info, 'activities')

  realtime_help: (info, type) ->
    data = info.values
    switch info.type
      when "new"
        @collection.add(_.extend(data, {_type: type}))

  fill_header: () ->
    $(@el).prepend('<h5 class="tab-header"><i class="icon-star"></i>活动消息</h5>')

  bind_items: () ->
    @urlRoot = "people/#{@current_user_login}/notifications"
    @collection = new Backbone.Collection()
    @collection.bind('reset', @addAll, @)
    @collection.bind('add', @addOne, @)
    @collection.fetch({ url: "#{@urlRoot}/unread?type=Activity" })

  addAll: (collecton) ->
    @$(".activities-list").html('')
    @collection.each (model) =>
      @addOne(model)

  addOne: (model) ->
    model.url = "#{@urlRoot}/#{model.id}"
    activity_view = new ActivityNoticeView({ model: model })
    @$(".activities-list").append(activity_view.render().el)
    activity_view.bind("remove_model", _.bind(@remove_model, @))

  remove_model: (id) ->
    model = @collection.get(id)
    @collection.remove model if model?   

class ActivityNoticeView extends Backbone.View
  tagName: 'li'
  template: _.template(
        "<img src='/default_img/t5050_default_avatar.jpg' class='pull-left img-circle' />
      <div class='user-info'>
      <div class='name'>
        <a href='#''><%= model.get('body') %></a>
      </div>
      <div class='type'><%= model.get('url') %></div>
      </div>")

  events:
    "click" : "show_modal"

  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @model.bind('remove', @remove, @)

  show_modal: () ->
    activity_model = new ActivityModel({ 
      id: @model.get('targeable_id') 
    })
    activity_model.fetch success: (model) =>
      view = new ActivityView({
        model    : model 
      })
      view.modal()     
      @trigger("remove_model", @model.id)

  render: () ->
    $(@el).html(@template(model: @model))
    @

  remove: () ->
    $.ajax(
      url: "#{@model.url}/enter"
      type: "GET",
      dataType: "json",
      success: =>

    )
    super


root.ActivitiesContainerView = ActivitiesContainerView