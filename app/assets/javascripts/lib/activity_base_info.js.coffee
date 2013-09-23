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

      type: "",

      input_name: "activity[attachment_ids]",

      data: []
    }
  }

  upload_options: {}

  initialize: (options) ->
    _.extend(@upload_options , @default_options.params, options.params)

    @$el = $(@el)
    if @upload_options.data.length > 0
      @load_attachments(@upload_options.data)

    @$el.on "ajax:success", _.bind(@ajax_success, @)

  ajax_success: () ->
    @$("img.preview").show()
    @atta_destroy_all()

  fetch_product: (shop_product_id) ->
    $.ajax
      type: "get"
      dataType: "json"
      data: {version_name: @upload_options.version_name }
      url: "/shop_products/#{shop_product_id}"
      success: (data) =>
        @load_info(data)

  load_info: (data) =>
    product = data.product
    if @options.params.type == "focus"
       @$('[name="activity[title]"]').val(product.name + '  聚焦');
    else
      @$('[name="activity[title]"]').val(product.name + '  竞价');

    @$('[name="activity[shop_product]"]').val(product.name);
    @$('[name="activity[shop_product_id]"]').val(product.id);
    @$('[name="activity[price]"]').val(product.price);
    @$('[name="activity[activity_price]"]').val(product.price);
   
    @$('ul.product_selector').hide();
    @load_attachments(product.attachments)

  load_attachments: (attachments) ->
    @$("img.preview").hide()
    @atta_destroy_all()
    @attas = new AttachmentUpload({
      el: @$(".attachment-list"),
      data: attachments,
      default_enabled: false,
      limit: 5,
      params: @upload_options
    })

  atta_destroy_all: () ->
    if @attas?
      @attas.destroy_all()

  render: () ->
    @$el
