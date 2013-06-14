# 活动上传

root = window

class ActivityUploads extends Backbone.Collection
  comparator: (a, b) ->
    if a.get("number") > b.get("number")
      -1
    else if a.get("number") < b.get("number")
      1
    else
      0

class ActivityUploadView extends Backbone.View
  tagName: "li"
  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @$el.html("<img class='img-rounded' src='#{@model.get("url")}' />")

  render: () ->
    @$el

class root.ActivityUploadListView extends Backbone.View
  tagName: "ul"
  className: "attachment_panel"
  default_options: {
    url_upload: "",

    blank_url: "",

    version_name: ""
  }

  def_options: {}

  initialize: (options) ->
    _.extend(@def_options , @default_options, options)
    @$el = $(@el)
    @activity_uploads = new ActivityUploads()
    @activity_uploads.bind("add", @add_view, @)
    @activity_uploads.add(url: @def_options.blank_url)

  load_attachments: (data) ->
    _.each data, (model) =>
      @activity_uploads.add(model)

  add_view: (model) ->
    model.set(number: @activity_uploads.length)
    view = new ActivityUploadView(model: model)
    @$el.append(view.render())

  upload: () ->
    @fileupload = new qq.FileUploader({
      element : @attachment_upload_panle[0],
      allowedExtensions : ['jpg', 'jpeg', 'png', 'gif'],
      sizeLimit : 1048576, # max size: 1MB
      minSizeLimit : 0, # min size
      debug : true,
      multiple : false,
      action : "#{@def_options.url_upload}/upload",
      inputName : "attachable",
      cancelButtonText : "取消上传",
      uploadButtonText : '<i class="icon-upload icon-white"></i> 上传头像',
      onComplete : _.bind(@complete_callback, @),
      onSubmit : _.bind(@submit_before_callback, @),
      messages : @messages()
    })

  render: () ->
    @$el

  complete_callback: (id, filename, data) ->

  submit_before_callback : (id, filename) ->
    @fileupload.setParams(
      authenticity_token: $("meta[name=csrf-token]").attr("content"),
      version_name: this.def_options.version_name
    )

  messages: () ->
    {
      typeError: "请选择正确的{file}头像图片，只支持{extensions}图片",
      sizeError: "{file}头像图片，超过{sizeLimit}了！"
    }