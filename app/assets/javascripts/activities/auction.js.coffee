# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#= require ../lib/activity_base_info

root = window || @

class root.ActivityAuctionView extends ActivityBaseInfoView

  initialize: () ->
    super

  fill_info: (data) ->
    product = data.product
    @$('[name="activity[title]"]').val(product.name + ' 竞价')
    @$('[name="activity[shop_product_id]"]').val(product.id)
    @$('[name="activity[price]"]').val(product.price)
    @$('[name="activity[activity_price]"]').val(product.price)

    start_time = new Date()
    end_time = new Date()
    start_time.setDate(start_time.getDate() + 1)
    end_time.setDate(end_time.getDate() + 8)
    @$('[name="activity[start_time]"]').val(start_time.format("MM/dd/yyyy"))
    @$('[name="activity[end_time]"]').val(end_time.format("MM/dd/yyyy"))

    @$('ul.product_selector').hide();
    @load_attachments(product.attachments)
    