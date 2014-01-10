
root = (window || @)

class Collection extends Backbone.Collection

class root.CardItemView extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)

    @model.bind("remove", @remove, @)
    @model.bind("change:state", @change_state, @)
    @model.bind("change:total", @change_total, @)
    @model.bind("change:register", @register_view, @)
    @register_view()

  remove: () ->
    @card.remove() unless _.isEmpty(@card)
    super

  change_total: () ->
    atotal = @$(".actions .atotal")
    tag = atotal.text().trim().substring(0, 1)
    atotal.html("#{tag} #{@model.get('total')}")

  change_state: () ->
    @change_table_state()

  get_register_view: () ->

  register_view: () ->
    if @model.get("register")
      @card = @get_register_view()

  card_change_state: () ->
    @change_table_state()

  set_state: (state) ->
    @model.attributes.state = state
    @model._currentAttributes.state = state

  syn_state: (state, state_title) ->
    @set_state(state)
    @model.set(state_title: state_title)

  change_table_state: () ->
    @$(".card_item_header .state-label").html(
      @model.get("state_title"))

class root.CardItemListView extends Backbone.View

  initialize: (options) ->
    @$el = $(@el)
    @remote_url = options.remote_url
    @columns_options ?= {}

    @collection = new Collection
    @collection.url = @remote_url
    @collection.bind("add", @_add_one, @)
    @client = window.clients
    @reset()
    @load_table_list()

  _add_one: (model) ->
    elem = model.get("elem")
    delete model.attributes.elem

    @add_one(elem, model)

  reset: () ->

  add_one: (elem, model) ->

  add_elem: (el) ->
    @collection.add(
      elem: $(el),
      register: false,
      id: $(el).attr('data-value-id'))

  register: (id) ->
    model = @collection.get(id)
    model.set(register: true) unless _.isEmpty(model)

  load_table_list: () ->
    @table = new TransactionTwoColumnsViewport(_.extend({
      el: @$el,
      remote_url: @remote_url,
      registerView: (view) =>  
        state = view.model.get("fetch_state")
        delete view.model.attributes.fetch_state
        @add_elem(view.$el) if !_.isEmpty(state) && state                   

        @register(view.model.id)
    }, @columns_options))