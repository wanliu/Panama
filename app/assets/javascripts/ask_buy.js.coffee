
#= require lib/attachment_upload

root = window || @

class root.AskBuyView extends Backbone.View

  params: {
    url_upload: "",

    default_img_url: "",

    version_name: "100x100",

    template: "",

    input_name: "ask_buy[attachment_ids]",

    data: []
  }

  upload_params: {}

  initialize: () ->
    _.extend(@upload_params, @params, @options.params)
    @$price = @$("#ask_buy_price")
    @init_attachment(@upload_params.data)

  fetch_product: (product_id) ->
    return if _.isEmpty(product_id)
    $.ajax(
      type: "get",
      url: "/products/#{product_id}/base_info",
      data: {version_name: @upload_params.version_name},
      success: (product) =>
        @atta.destroy_all()
        @$price.val(product.price)
        @init_attachment(product.attachments)
    )

  init_attachment: (attachments) ->
    @atta = new AttachmentUpload(
      el: @$(".attachment-list"),
      data: attachments,
      default_enabled: false,
      limit: 4,
      params: @upload_params
    )