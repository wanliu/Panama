
root = window || @

class Collection extends Backbone.Collection

class PropertyValue extends Backbone.View
  events: {
    "click" : 'chose',
  }

  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @$checkbox = @$("input:checkbox")
    @model.bind("active_chose", _.bind(@active_chose, @))

  chose: () ->
    @model.set(status: !@model.get("status"))

  active_chose: () ->
    @$checkbox.attr("checked", @model.get("status"))

class PropertyView extends Backbone.View
  events: {
    "click .chose-multi" : "display_bar"
    "click .cancel" : "close_multi",
    "click .confirm" : "confirm_chose"
  }
  initialize: () ->
    @$el = $(@el)

    @values = new Collection()
    @values.bind("add", @add_value, @)
    @model.bind("change_values_status", _.bind(@change_values_status, @))
    @model.bind("change:chose_state", @change_chose_state, @)
    @model.set(chose_state: "odd")
    @load_values()
    @$btn_confirm = @$("input.confirm")

  load_values: () ->
    @$(".values li.value").each (i, el) =>
      @values.add(
        el: $(el),
        value: $(el).attr("data-value"),
        status: false
      )

  add_value: (model) ->
    el = model.get("el")
    delete(model.attributes.el)
    model.bind("change:status", @change_state, @)
    view = new PropertyValue(
      el: $(el),
      model: model
    )

  change_state: () ->
    if @model.get("chose_state") == "odd"
      model = @find_model()
      unless _.isEmpty(model)
        model.trigger("active_chose")
        @add_condition(
          title: @model.get("title"),
          name: @model.get("name"),
          values: [model.get('value')]
        )
    else if @model.get("chose_state") == "even"
      @$btn_confirm.removeClass("disabled") unless _.isEmpty(@chose_value())
      @checked_chose()

  checked_chose: () ->
    @values.each (m) -> m.trigger("active_chose")

  add_condition: (opts) ->
    @$el.hide()
    @trigger("add_condition", opts)

  find_model: () ->
    model = @chose_value()[0]

  find_values: () ->
    models = @chose_value()
    _.map models, (m) -> m.get('value')

  chose_value: () ->
    @values.where(status: true)

  change_values_status: () ->
    @$el.show()
    @clear_all_chose_state()

  clear_all_chose_state: () ->
    _.each @chose_value(), (model) ->
      model.attributes.status = false
      model._currentAttributes.status = false

    @checked_chose()

  change_chose_state: () ->
    if @model.get("chose_state") == "odd"
      @$el.addClass("odd").removeClass("even")
      @clear_all_chose_state()
    else if @model.get("chose_state") == "even"
      @$el.addClass("even").removeClass("odd")

  display_bar: () ->
    @model.set(chose_state: "even")

  close_multi: () ->
    @model.set(chose_state: "odd")

  confirm_chose: () ->
    return if @$btn_confirm.hasClass("disabled")
    return if _.isEmpty(@chose_value())

    @add_condition(
      title: @model.get('title'),
      name: @model.get("name"),
      values: @find_values()
    )

class ConditionView extends Backbone.View
  tagName: "li",
  className: "condition"

  events: {
    "click .close-label" : "close"
  }

  render: () ->
    values = @model.get("values")
    span = $('<span class="label label-important data-toggle="tooltip" data-placement="top" ">
      <span class="title"></span>
      <a href="javascript:void(0)" class="close-label"></a>
    </span>')

    title = span.find(".title")
    str_value = values
    str_value = values.join("、") if _.isArray(values)
    span.attr("title", @get_title(str_value))
    str_value = "#{str_value.slice(0, 5)}..." if str_value.length > 5
    title.html(@get_title(str_value))
    @$el.html(span)

  get_title: (str_value) ->
    "#{@model.get('title')}: #{str_value}"

  close: () ->
    @trigger("remove", @model)
    @remove()

class ConditionList extends Backbone.View

  initialize: () ->
    @$el = $(@el)
    @collection = new Collection()
    @collection.bind("add", @add_one, @)

  add_one: (model) ->
    view = new ConditionView(
      model: model
    )
    @$el.append(view.render())
    view.bind("remove", _.bind(@remove, @))

  add: (opts) ->
    @collection.add(opts)

  remove: (model) ->
    @collection.remove(model)
    @trigger("remove_condition", model.toJSON())

class FilterOptions extends Backbone.View
  default_params: {
    change: (options) ->
  }

  initialize: () ->
    @params = {}
    _.extend(@params, @default_params, @options.params)
    @properties = new Collection()
    @properties.bind("add", @add_property, @)

    @condition_view = new ConditionList(
      el: @$(".breadcrumb")
    )
    @condition_view.bind("remove_condition", _.bind(@remove_condition, @))

    @load_properties()

  load_properties: () ->
    @$(".properties>.property").each (i, el) =>
      li = $(el).find(".name")
      @properties.add(
        title: li.attr("data-value-title"),
        name: li.attr("data-value-name"),
        el: $(el)
      )

  add_property: (model) ->
    el = model.get("el")
    delete(model.attributes.el)
    view = new PropertyView(
      el: el,
      model: model
    )
    view.bind("add_condition", _.bind(@add_condition, @))

  add_condition: (options) ->
    @condition_view.add(options)
    @change()

  remove_condition: (options) ->
    model = @properties.where(name: options.name)[0]
    unless _.isEmpty(model)
      model.trigger("change_values_status")
      @change()

  change: () ->
    if _.isFunction(@params.change)
      @params.change(@condition_view.collection.toJSON())


root.FilterOptions = FilterOptions
