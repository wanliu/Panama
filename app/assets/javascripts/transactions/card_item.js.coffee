
root = (window || @)

class Collection extends Backbone.Collection

class root.CardItemView extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)

    @model.bind("remove", @remove, @)
    @model.bind("change:state", @change_state, @)
    @model.bind("change:stotal", @change_stotal, @)
    @model.bind("change:register", @register_view, @)
    @register_view()
    @$header = @$(".card_item_header")

  remove: () ->
    @card.remove() unless _.isEmpty(@card)
    super

  change_stotal: () ->
    atotal = @$(".actions .atotal")
    tag = atotal.text().trim().substring(0, 1)
    atotal.html("#{tag} #{@model.get('stotal')}")

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
    @bind_notify_state()

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
      el: @$(".wrap_list"),
      remote_url: @remote_url,
      registerView: (view) =>  
        @set_type_state(view.model.id)
        state = view.model.get("fetch_state")
        delete view.model.attributes.fetch_state
        @add_elem(view.$el) if state? && state                   

        @register(view.model.id)
    }, @columns_options))

  open_on: (callback = (id) ->) ->    
    @table.route.on "route:open", (id) =>
      callback.call(@, id)

  home_on: (callback = () ->) ->
    @table.route.on "route:home", () =>
      callback.call(@)

  hide: () ->
    @$el.hide()

  show: () ->
    @$el.show()

  bind_notify_state: () ->
    @open_on (id) -> @set_type_state(id)
    @home_on () -> @set_type_state(null)        

  set_type_state: (value) ->
    notifyDisposeState.setTypeValue(@table.spaceName, value)
    

