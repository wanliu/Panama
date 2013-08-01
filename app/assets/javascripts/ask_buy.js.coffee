
#= require lib/attachment_upload

root = window || @

class root.AskBuyView extends Backbone.View

  params: {
    url_upload: "",

    default_img_url: "",

    version_name: "100x100",

    template: "",

    input_name: "ask_buy[attachment_ids]"
  }

  upload_params: {}

  initialize: () ->
    _.extend(@upload_params, @params, @options.params)
    @$title = @$(".ask_buy_title")
    @$price = @$("#ask_buy_price")
    @init_attachment([])

  fetch_product: (product_id) ->
    return if _.isEmpty(product_id)
    $.ajax(
      type: "get",
      url: "/products/#{product_id}/base_info",
      success: (product) =>
        @atta.destroy_all()
        @$title.val(product.name)
        @$price.val(product.price)
        @init_attachment(product.attachments)
    )

  init_attachment: (attachments) ->
    @atta = new AttachmentUpload({
      el: @$(".attachment-list"),
      data: attachments,
      default_enabled: false,
      limit: 4,
      params: @upload_params
    })