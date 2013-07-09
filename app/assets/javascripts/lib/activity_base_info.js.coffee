# 活动上传

#= require lib/attachment_upload

root = window || @

class root.ActivityBaseInfoView extends Backbone.View
  default_options: {

    params: {
      url_upload: "",

      default_img_url: "",

      version_name: "100x100",

      template: "",

      input_name: "activity[attachment_ids]",

      default_enabled: false,

      limit: 5
    }
  }

  upload_options: {}

  initialize: (options) ->
    _.extend(@upload_options , @default_options.params, options.params)

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
    @$('[name="activity[description]"]').val(product.name + '  竞价');
    @$('ul.product_selector').hide();
    @load_attachments(product.attachments)

  load_attachments: (attachments) ->
    @$("img.preview").remove()
    @$(".attachment-list>li").remove()

    new AttachmentUpload({
      el: @$(".attachment-list"),
      data: attachments,
      default_enabled: false,
      limit: 5,
      params: @upload_options
    })

  render: () ->
    @$el
