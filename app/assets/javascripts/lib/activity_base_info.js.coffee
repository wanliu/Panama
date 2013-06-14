# 活动上传

#= require admins/shops/product_upload

root = window

class root.ActivityBaseInfoView extends Backbone.View
  default_options: {

    params: {
      url_upload: "",

      default_img_url: "",

      version_name: "",

      template: "",

      input_name: ""
    }
  }

  def_options: {}

  initialize: (options) ->
    _.extend(@def_options , @default_options, options)

  fetch_product: (product_id) ->
    $.ajax
      url: "/products/#{product_id}/base_info"
      success: (data) =>
        @load_info(data)

  load_info: (product) ->
    @$('[name="activity[product]"]').val(product.name);
    @$('[name="activity[product_id]"]').val(product.id);
    @$('[name="activity[price]"]').val(product.price);
    @$('[name="activity[activity_price]"]').val(product.price);
    @$('[name="activity[activity_name]"]').val(product.name + 'jingjia');
    @$('ul.product_selector').hide();
    @load_attachments(product.attachments)

  load_attachments: (attachments) ->
    @$("img.private").remove()
    @$(".attachment_panel>li").remove()
    new ProductUpload({
      el: @$(".attachment_panel"),
      data: attachments,
      default_enabled: false,
      limit: 5,
      params: @def_options.params
    })

  render: () ->
    @$el
