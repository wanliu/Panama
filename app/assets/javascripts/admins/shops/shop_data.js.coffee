root = window || @
class root.ShopDataView extends Backbone.View
  events: 
    "click .submit_update" : "submit_update"

  initialize: (options) ->
    _.extend(@, options)
    @el = $(@el)

  submit_update: () =>
    data = {shop_id: @shop_id}
    $.ajax({
      type: "put",
      dataType: "json",
      data: _.extend(data,  @$("form").serializeHash()),
      url: @$("form").attr("action"),
      success: (data) ->
        window.location.href = "/shops/#{ data.shop_name }/admins/shop_info"
      error: (message) ->
        ms = JSON.parse(message.responseText)
        pnotify(text: ms.join("<br />"), type: "error")
    })
    false