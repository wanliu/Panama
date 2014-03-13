# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require ../lib/activity_base_info
root = window || @
class root.ActivityFocusView extends ActivityBaseInfoView
  events:
    "click .add_range": "clone_elem"

  initialize: () ->
    super

  fill_info: (data) ->
    @$('[name="activity[title]"]').val(data.name);
    @$('[name="activity[shop_product_id]"]').val(data.id);

    @$('ul.product_selector').hide();
    @load_attachments(data.product.attachments)

  clone_elem: () ->
    one_line = @$(".bettwen:eq(0)").clone(true)
    iden = @$(".bettwen").length
    $price = $(".activity_activity_price", one_line)
    $number = $(".activity_people_number", one_line)
    $(".bar", one_line).html('')
    $number.val('')
    $price.val('')
    $number.attr("name", "activity[people_number][#{iden}]")
    $price.attr("name", "activity[activity_price][#{iden}]")

    @$(".bettwen-warp").append(one_line)
