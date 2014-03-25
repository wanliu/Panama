#= require jquery
#= require backbone

exports = window || @

class CartItemView extends Backbone.View

  events: 
    'change input.amount'  : 'countCart'
    'change .check-item' : 'checkItem'

  initialize: (options) ->
    _.extend(@, options)
    @item_id = $(@el).data('id')
    @$total = @$(".total")

  checkItem: () ->
    @parent.checkItem()

  countCart: () ->
    amount = @$("input.amount").val() 
    if !_.isEmpty(amount) &&  !isNaN(amount)
      $.ajax({
        type: "post",
        url: "/people/#{@login}/cart/#{@item_id}/change_number",
        data : { amount: amount }
        dataType: "json"
      }).success((data, xhr, res) =>
        @set_total(data.total)
        @parent.countCart()
      )

  set_total: (total) ->
     tag = @$total.text().trim().substring(0, 1)
     @$total.html("#{tag} #{total}")


class root.CartContainer extends Backbone.View
  events:
    'change .check-all' : 'checkAll'
    'click .submit-cart': 'submitCart'
    'click .remove-item': 'removeItem'

  @getInstance = (options) ->
    CartContainer.instance ||= new CartContainer(options)

  initialize: (options) ->
    _.extend(@, options)
    _.each @$(".item-tr"), ($item) =>
      new CartItemView({ el: $item, parent: @, login: @login })
    @$('.item-tr .controls').css('margin-left', 0)
    @$form = @$('form#cartForm')
    @render()

  render: () ->
    @$('.check-all').attr('checked', true)
    @checkAll()

  submitCart: () ->
    return false if  @$(".submit-cart").hasClass("disabled")
    return pnotify(type: 'error', text: '请勾选要结算的商品') unless @$('.check-item:checked').length > 0   
    @$(".submit-cart").addClass("disabled") 
    $.ajax(
      url: @$form.attr("action"),
      type: @$form.attr('method'),
      data: @$form.serializeHash(),
      error: (data) =>
        try
          ms = JSON.parse(data.responseText)
          pnotify(text: ms.join("<br />"), type: "error")
          @$(".submit-cart").removeClass("disabled")
        catch error
          pnotify(text: data.responseText, type: "error")
          @$(".submit-cart").removeClass("disabled")

    )
    false
    

  checkItem: () ->
    @countCart()
    flag = @$('.check-item').length is @$('.check-item:checked').length
    @$('.check-all').attr('checked', flag)

  removeItem: () ->
    rows = @$('.check-item:checked')
    return pnotify(text: '请勾选要移除的商品') unless rows.length > 0
    rows.parents('.item-tr').fadeOut()

    item_ids = []
    items = @$('form#cartForm').serializeHash().items
    _.each items, (item) =>
      item_ids.push(~~item.id) if item.checked is 'on'

    $.ajax({
      type: "post",
      url: "/people/#{@login}/cart/move_out",
      data : { item_ids: item_ids }
      dataType: "json"
    }).success((data, xhr, res) =>
      pnotify(text: '已经从购物车中移除')
      rows.parents('.item-tr').remove()
      @countCart()
    )

  checkAll: () ->
    flag = @$('.check-all').attr('checked') is 'checked'
    @$('.check-item').attr('checked', flag)
    @countCart()

  countCart: () ->
    prices = 0
    amounts = 0
    items = @$('form#cartForm').serializeHash().items
    _.each items, (item) =>
      if item.checked is 'on'
        amount = ~~item.amount
        amounts += amount
        prices += amount * parseFloat(item.price)
    @$('.quantity-total').html(amounts)
    @$('.price-total').html('￥' + prices.toFixed(2))

