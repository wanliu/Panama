#管理配送方式

root = window || @

class Manner extends Backbone.View
  events: {
    "click" : "chose_manner"
  }

  initialize: (options) ->
    _.extend(@, options)

  chose_manner: () ->
    @model.set(state: true)
    @trigger("change_state", @model)

class root.TransactionManner extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)
    @collection = new Backbone.Collection
    @collection.bind("add", @add_one, @)
    @$chose = @$(".chose_item")
    @load_list()

  add_one: (model) ->
    elem = model.get("elem")
    delete model.attributes.elem
    view = new Manner(
        model: model,
        el: elem)
    view.bind("change_state", _.bind(@change_state, @))

  change_state: (m) ->
    @collection.each (model) =>
      unless m.id == model.id
        model.attributes.state = false
        model._currentAttributes.state = false

    @$chose.data("values", m.toJSON())
    @select(m.toJSON())

  load_list: () ->
    lis = @$("ul>li")
    _.each lis, (li) =>
      item = {state: false, elem: $(li)}
      _.each @keys, (key) =>
        item[key] = $(li).attr("data-value-#{key}")

      @collection.add(item)

  select: (data) ->

  default_item: (data) ->
    m = @collection.where(data)[0]
    @change_state(m) unless _.isEmpty(m)