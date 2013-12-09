
root = (window || @)

class Transaction extends Backbone.Model

  load_template: (callback = () ->) ->
    $.ajax(
      url: "#{@url()}",
      success: callback
    )

class Transactions extends Backbone.Collection

  model: Transaction

class TransactionDialogView extends Backbone.View

  initialize: () ->
    _.extend(@, @options)
    @$el = $(@el)

  animate: () ->
    style = @el_css()
    @$el.wrap("<div class='wrap_transaction' />")
    @$el.wrap("<div class='panel' />").parent().css(style)
    $load_info = $(@load_elem()).prependTo(@$el.wrap("<div class='dialog modal' />").parent())
    $load_info.css(
      width: style.width / 3,
      height: style.height / 3
    )
    $load_info.animate style, () =>
      $load_info.remove()
      @$el.unwrap().unwrap().unwrap()

  hide: () ->
    @$el.addClass("hide")

  render: () ->
    @$el

  load_elem: (elem) ->
    "<div class='load_info'>
      <img src='/assets/loading_max.gif'/>正在加载...
    </div>"

  el_css: () ->
    {width: @$el.outerWidth(), height: @$el.outerHeight()}

class TransactionView extends Backbone.View
  events: {
    "click" : "show_detail"
  }

  show_detail: () ->
    @trigger("dialog_show", @model)


class DisplayDialogView extends Backbone.View

  events: {
    "click .modal-header .next" : "next",
    "click .modal-header .previous" : "previous",
    "click .modal-header .close" : "close"
  }

  initialize: () ->
    _.extend(@, @options)
    @$el = $(@el)
    @transactions = new Transactions()
    @transactions.url = @remote_url
    @view = new TransactionDialogView(el: @$el)
    @$previous = @$(".modal-header .previous")
    @$next = @$(".modal-header .next")

  show: (model) ->
    @set_current_model(model)
    @load_template (data) =>
      @view.animate()

  load_template: (callback = (data) ->) ->
    @current_model.load_template (data) =>
      @paging()
      @$el.removeClass("hide")
      @render(data)
      callback.call(@, data)

  render: (data) ->
    @$(">.modal-body").html(data)
    @$(">.modal-header .title").html("编号: #{@current_model.get('number')}订单")

  next: () ->
    index = @find_index()
    if index < @transactions.length - 1
      @set_current_model @transactions.models[++index]
      @load_template()

  previous: () ->
    index = @find_index()
    if index > 0
      @set_current_model @transactions.models[--index]
      @load_template()

  add: (data) ->
    @transactions.add data

  set_current_model: (model) ->
    @current_model = model

  close: () ->
    @$el.addClass("hide")

  find_index: () ->
    _.indexOf(@transactions.models, @current_model)

  paging: () ->
    index = @find_index()
    @paging_active(index <= 0, @$previous)
    @paging_active(index >= @transactions.length - 1, @$next)

  paging_active: (state, elem) ->
    if state
      elem.addClass("disabled")
    else
      elem.removeClass("disabled")

class root.TransactionListView extends Backbone.View

  initialize: () ->
    _.extend(@, @options)
    @dialog_view = new DisplayDialogView(
      el: $(".order_dialog"),
      remote_url: @remote_url)
    @load_view()

  load_view: () ->
    _.each @$(".item"), (el) =>
      @dialog_view.add({
        number: $(el).attr('data-value-number'),
        id: $(el).attr('data-value-id')
      })
      view = new TransactionView(
        el: $(el),
        model: @dialog_view.transactions.last()
      )
      view.bind("dialog_show", _.bind(@dialog_show, @))

  dialog_show: (model) ->
    @dialog_view.show(model)
