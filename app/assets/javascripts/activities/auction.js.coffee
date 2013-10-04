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

    @$('[name="activity[title]"]').val(product.name + ' 竞价');
    @$('[name="activity[shop_product_id]"]').val(product.id);
    @$('[name="activity[price]"]').val(product.price);
    @$('[name="activity[activity_price]"]').val(product.price);

    @$('ul.product_selector').hide();
    @load_attachments(product.attachments)