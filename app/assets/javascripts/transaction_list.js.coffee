
root = (window || @)

class Transaction extends Backbone.Model

  load_template: (callback = () ->) ->
    $.ajax(
      url: "#{@url()}/dialog",
      success: callback
    )

class TransactionDialogView extends Backbone.View
  events: {
    "click .modal-header .close" : "close"
  }
  initialize: () ->
    _.extend(@, @options)
    @$el = $(@el)
    style = @el_css()
    @$el.wrap("<div class='wrap_transaction' />")
    @$el.wrap("<div class='panel' />").parent().css(style)
    $load_info = $(@load_elem()).prependTo(@$el.wrap("<div class='dialog modal' />").parent())
    $load_info.css(
      width: style.width / 3,
      height: style.height / 3
    )
    @$el.removeClass("hidden")
    $load_info.animate style, () =>
      $load_info.remove()
      @$el.unwrap().unwrap().unwrap()

  close: () ->
    @remove()

  render: () ->
    @$el

  load_elem: (elem) ->
    "<div class='load_info'>
      <img src='/assets/loading_max.gif'/>正在加载...
    </div>"

  el_css: () ->
    {width: @$el.outerWidth(), height: @$el.outerHeight()}

class DisplayDialogView extends Backbone.View

  events: {
    "click .more" : "more"
  }

  more: () ->
    @model.load_template (data) =>
      @view = new TransactionDialogView(
        el: $(data).appendTo("body")[0],
        model: @model)


class root.TransactionListView extends Backbone.View

  initialize: () ->
    _.extend(@, @options)
    @load_view()

  render: () ->

  load_view: () ->
    _.each @$(".item"), (el) =>
      model = new Transaction({
        id: $(el).attr('data-value-id')})

      model.urlRoot = @remote_url
      view = new DisplayDialogView(
        model: model
        el: $(el))

  bindView: (view) ->


