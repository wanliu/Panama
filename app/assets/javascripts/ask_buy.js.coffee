
#= require lib/attachment_upload

root = window || @

class root.AskBuyView extends Backbone.View
  # 'keyup input[name="ask_buy[title]"]' : 'checkEmpty' # fix me, keyup not work

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
    @$title = @$(".ask_buy_title")
    @init_attachment(@upload_params.data)

    @$el.on "ajax:success", _.bind(@ajax_success, @)
    @$('input[name="ask_buy[title]"]').bind('keyup', (event) => @checkEmpty(event) )

  checkEmpty: (event) ->
    $input = $(event.currentTarget)
    return if _.isEmpty($input.val().trim())
    $input.siblings('.help-inline').remove()
    $input.parents('.control-group').removeClass('error')

  ajax_success: () ->
    pnotify({title: '提醒', text: "求购信息发布成功！"})
    @atta_destroy_all()

  fetch_product: (product_id) ->
    return if _.isEmpty(product_id)
    $.ajax(
      type: "get",
      url: "/products/#{product_id}/base_info",
      data: {version_name: @upload_params.version_name},
      success: (product) =>
        @attas.destroy_all()
        @$price.val(product.price)
        @$title.val(product.name)
        @init_attachment(product.attachments)
    )

  atta_destroy_all: () ->
    if @attas?
      @attas.destroy_all()
      @attas.add_blank_preview()

  init_attachment: (attachments) ->
    @attas = new AttachmentUpload(
      el: @$(".attachment-list"),
      data: attachments,
      default_enabled: false,
      limit: 4,
      params: @upload_params
    )

