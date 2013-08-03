#= require backbone
#= require lib/hogan

class Preview extends Backbone.View
  events: {
    "click .close" : "hide"
  }
  initialize: (options) ->
    _.extend(@, options)
    @template = Hogan.compile(@template)
    @fetch_dialog()

  fetch_dialog: () ->
    $.ajax(
      url: "/ask_buy/#{@asK_buy_id}",
      success: (data) =>
        @render(data)
    )

  render: (data) ->
    @el.html(@template.render(data))

  hide: () ->
    @$(".ask_buy_preview_dialog").remove()



class root.AskBuyPreview extends Backbone.View
  events: {
    "click .ask_buy .in-box" : 'preview'
  }

  initialize: (options) ->
    _.extend(@, options)

  preview: (event) ->
    event_el = $(event.currentTarget.parentElement).parent()
    asK_buy_id = event_el.attr('ask-buy-id')
    new Preview(
      el: @parent_el,
      asK_buy_id: asK_buy_id,
      template: @preview_template)
