root = window || @
class root.ActivityBuyView extends Backbone.View
  events: {
    "click .address_bar"  : "toggle",
    "click button.confirm": "buy"
  }
  
  initialize: () ->
    #@activity_id = @options.activity_id
    @model.bind("modal", _.bind(@modal, @))
    @buy_btn = @$('button.confirm')
    @amount = @options.amount || 1;
    @load_template (html) ->
      @render(html)

  load_template: (callback) ->
    $.ajax(
      url: "/activities/#{@model.id}/buy.dialog",
      success: (html) =>
        callback.call(@, html)
    )

  modal: () ->
    $("body").addClass("noScroll")
    @$dialog = @$("#auction_buy_dialog") 
    @$dialog.modal()

  render: (html) ->
    @$el.html(html)
    $("#popup-layout").append(@el)       
    @modal()
    @load_binding()    
    @delegateEvents()

  load_binding: () ->
    @$address_info = @$(".address-info")
    @$form = @$("form.buy_activity")
    @$dialog.on "hidden", () => @close()
    @$dialog.on "shown", () =>  
      @load_depend_chose()
      @address_chose()

    @$('input[name="product_item[amount]"]').val(@amount)

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
      no_results_text : "没有以该关键词开头的地址",
      select: () =>
        @$address_info.slideUp();

    })

  toggle: () ->
    if @$address_info.css("display") == "none"
      @$('.search-choice-close').trigger("mouseup")

    @$address_info.slideToggle()

  close: () ->
    $("body").removeClass("noScroll")

  _disable_buy: () ->
    @buy_btn.addClass('disabled')

  _enable_buy: () ->
    @buy_btn.removeClass('disabled')

  buy: () ->
    return if @buy_btn.hasClass('disabled')
    @_disable_buy()
    data = @$form.serializeHash()
    address = data.address

    if _.isEmpty(address.id)
      if _.isEmpty(address.province_id) || 
      _.isEmpty(address.city_id) || 
      _.isEmpty(address.area_id) ||
      _.isEmpty(address.contact_name) ||
      _.isEmpty(address.contact_phone) ||
      _.isEmpty(address.road) ||
      _.isEmpty(address.zip_code)
        pnotify(text: "请添加联系地址！", type: "warning")
        @_enable_buy()
        return false

    amount = data.product_item.amount    
    unless _.isFinite(amount) && ~~amount >= 1 && ~~amount == parseFloat(amount)
      pnotify(text: "数量必须为不小于1的整数！", type: "warning")
      @_enable_buy()
      return false

    $.ajax(
      url: @$form.attr("action"),
      data: data,
      type: "POST",
      error: (data, xhr, res) =>
        try
          message = JSON.parse(data.responseText).join("<br />")
          pnotify(text: message, type: "error")
        catch error
          pnotify(
            text: xhr.responseText,
            type: "error")
          @_enable_buy()
    )  

