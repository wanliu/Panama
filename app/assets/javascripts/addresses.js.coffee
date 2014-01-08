
root = window || @

class root.AddressesView extends Backbone.View
  formName: "address"

  initialize: (options) ->  
    _.extend(@, options)
    @$el = $(@el)
    @$new_form = @$("form#new_address_form")
    @$edit_form = @$("form#edit_address_form")

  events:
    "click #new_address .save-button" : "new_address"
    "click .address .edit-button"     : "update_address"

  new_address: (event) ->
    data = @$new_form.serializeHash()
    return false unless @valid_data(data[@formName] || {})

    $.ajax(
      url: @$new_form.attr("action"),
      data: data,
      type: 'POST',
      success: () =>
        window.location.reload()

      error: (data) =>
        ms = JSON.parse(data.responseText)
        pnotify(text: ms.join("<br />"), type: "error")
    )
    false

  update_address: (event) ->
    data = @$edit_form.serializeHash()
    return false unless @valid_data(data[@formName] || {})
    $.ajax(
      url: @$new_form.attr("action"),
      data: data,
      type: 'PUT',
      success: () =>
        window.location.reload()        
      error: (data) =>
        ms = JSON.parse(data.responseText)
        pnotify(text: ms.join("<br />"), type: "error")
    )
    false

  valid_data: (data) ->    
    if _.isEmpty(data.province_id)
      pnotify(text: "请选择省!", type: "warning")
      return false

    if _.isEmpty(data.city_id)
      pnotify(text: "请选择市!", type: "warning")
      return false

    if _.isEmpty(data.area_id)
      pnotify(text: "请选择县!", type: "warning")
      return false

    if _.isEmpty(data.road)
      pnotify(text: "请输入街道!", type: "warning")
      return false

    if _.isEmpty(data.contact_name)
      pnotify(text: "请输入联系人!", type: "warning")
      return false

    if _.isEmpty(data.contact_phone)
      pnotify(text: "请输入联系电话!", type: "warning")
      return false

    unless /^\d{11}$|\d{3,4}-\d{6,8}(?:-\d{1,4})?$/.test(data.phone)
      pnotify(text: "请输入正确的联系电话", type: "warning")
      return false

    true


class root.AddressEditView extends Backbone.View
  events:
    "click .edit-button" : "update_address"

  update_address: (event) ->
    $.ajax(
      type: "POST",
      dataType: "JSON",
      data: @$("form").serialize(),
      url: @$("form").attr("action"),
      success: (data) =>
        @$(".address_input").val(data.address)
        @$('[name="shop_auth[address_id]"]').val(data.id)
        @$("#edit_address").modal('hide')
        pnotify({text: "修改地址成功！"})
      error: (xhr, status) =>
        ms = JSON.parse(xhr.responseText)
        pnotify({text: ms.join("<br />"), type: "error"})
    )
    false

