root = window || @
class root.ActivityBuyView extends Backbone.View
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
      url: "/activities/#{@activity_id}/buy.dialog",
      success: (html) =>
        callback.call(@, html)
    )

  render: (html) ->
    @$el.html(html)
    $("#popup-layout").html(@el)

    @load_binding()
    if $("body>.model-popup-backdrop").length <= 0
      @$backdrop = $("<div class='model-popup-backdrop in' />").appendTo("body")

    @delegateEvents()

  load_binding: () ->
    @$address_info = @$(".address-info")
    @$form = @$("form.buy_activity")
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
    @remove()
    @$backdrop.remove()

  buy: () ->
    $.ajax(
      url: @$form.attr("action"),
      data: @get_date(),
      type: "POST",
      dateType: "html",
      error: (xhr) =>
        @$el.html(xhr.responseText)
        @load_binding()
    )

  get_date: () ->
    values = @$form.serializeArray()
    data = {}
    _.each values, (val) -> data[val.name] = val.value
    data