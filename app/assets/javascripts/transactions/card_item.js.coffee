
root = (window || @)

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
