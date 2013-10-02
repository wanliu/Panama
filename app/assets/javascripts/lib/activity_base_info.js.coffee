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
        @fill_info(data)

  fill_info: (data) =>

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
