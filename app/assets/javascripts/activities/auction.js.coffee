# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#= require ../lib/activity_base_info

root = window || @

class root.ActivityAuctionView extends ActivityBaseInfoView

  initialize: () ->
    super

  fill_info: (data) ->    
    @inputs_val(data)

    @$('ul.product_selector').hide();
    @load_attachments(data.product.attachments)

  reset: () ->
    @inputs_val({
      id: "",
      price: "",      
      name: ""})

  inputs_val: (product) ->
    @$('[name="activity[title]"]').val(product.name)
    @$('[name="activity[shop_product_id]"]').val(product.id)
    @$('[name="activity[price]"]').val(product.price)
    @$('[name="activity[activity_price]"]').val(product.price)

###
class root.AuctionBuyView extends Backbone.View
  bodyClass: "noScroll"

  events: {
    "click .address_bar" : "toggle",
    "click [data-dismiss='modal']" : "close",
    "click button.confirm" : "buy"
  }
  
  initialize: () ->
    @activity_id = @options.activity_id
    @load_template (html) ->
      @render(html)

  load_template: (callback) ->
    $.ajax(
      url: "/activities/auction/#{@activity_id}/buy.dialog",
      success: (html) =>
        callback.call(@, html)
    )

  modal: () ->  
    $("body").addClass(@bodyClass)  
    @$("")

  render: (html) ->
    @$el.html(html)
    @$address_info = @$(".address-info")
    @$form = @$("form.buy_activity")
    $("#popup-layout").append(@el)

    @load_binding()    
    @delegateEvents()

  load_binding: () ->
    @load_depend_chose()
    @address_chose()

  load_depend_chose: () ->
    @depend_select(
      $(".address_province_id", @$address_info),
      $(".address_city_id", @$address_info),"")

    @depend_select(
      $(".address_city_id", @$address_info),
      $(".address_area_id", @$address_info),"/city/")

    @depend_select(
      $(".address_area_id", @$address_info),"","/city/")

  depend_select: (el, children, url) ->
    new DependSelectView({
      el: el,
      children: children,
      url: url
    })

  address_chose: () ->
    @$("select.address_id").chosen({
      allow_single_deselect : true,
      placeholder_text : "选择一个地址",
      no_results_text : "没有以该关键词开头的地址"
    })

  toggle: () ->
    @$address_info.toggle()

  close: () ->
    $("body").removeClass(@bodyClass)

  buy: () ->
    $.ajax(
      url: @$form.attr("action"),
      data: @get_date(),
      type: "POST",
      success: (xhr) ->

      error: (xhr) ->
        try
          message = JSON.parse(xhr.responseText).join("<br />")
          pnotify(text: message, type: "error")
        catch error
          pnotify(
            text: xhr.responseText,
            type: "error")
    )

  get_date: () ->
    @$form.serializeHash()
###
