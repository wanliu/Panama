#describe: 附件上传
#= require jquery
#= require backbone
#= require lib/fileuploader
#= require twitter/bootstrap/tooltip

root = window || @

class Attachment extends Backbone.Model
  set_url: (url) ->
    @urlRoot = url

class PreviewImage extends Backbone.View
  className: "preview_img"
  events:{
    "mouseover" : "show_nav",
    "mouseout" : "hide_nav",
    "click .delete" : "delete_attachment"
  }
  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @$el.html @img_template()
    @$el.append @val_template()
    @$el.append @nav_template()

  nav_template: () ->
    "<div class='img_nav'>
      <a href='javascript:void(0)' class='delete'>删除</a>
    </div>"

  img_template: () ->
    "<img src='#{@model.get("url")}' />"

  val_template: () ->
    "<input type='hidden' name='attachments[#{@model.id}]' value='#{@model.id}' />"

  render: () ->
    @$el

  show_nav: () ->
    @$(".img_nav").show()

  hide_nav: () ->
    @$(".img_nav").hide()

  delete_attachment: () ->
    @model.destroy success: (model, data) =>
      @remove()

class ImageUpload extends Backbone.View
  tagName: "span",
  className: "image_upload",
  events: {
    "click .upload_button" : "chose_upload"
  }
  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @init_upload()
    #@$(".upload_button").tooltip(title: "上传图片")

  init_upload: () ->

    @fileupload = new qq.FileUploader({
      element : @el,
      allowedExtensions : ['jpg', 'jpeg', 'png', 'gif'],
      sizeLimit : 1048576, # max size: 1MB
      minSizeLimit : 0, # min size
      debug : true,
      multiple : false,
      action : "#{@remote}/upload",
      dragText: "",
      inputName : "attachable",
      cancelButtonText : "取消上传",
      uploadButtonText : @upload_button(),
      onComplete : _.bind(@complete, @),
      onSubmit : _.bind(@submit_before, @),
      messages : @messages()
    })

  upload_button: () ->
    '<a class="btn btn-mini upload_button">
      <i class="icon-upload"></i>
    </a>'

  messages: () ->
    {
      typeError : "请选择正确的{file}头像图片，只支持{extensions}图片",
      sizeError : "{file}头像图片，超过{sizeLimit}了！"
    }

  complete: (id, filename, data) ->
    if data.success
      attachment = JSON.parse(data.attachment)
      model = new Attachment(attachment)
      model.set_url(@remote)
      view = new PreviewImage(model: model)
      @preview_el.append(view.render())

  submit_before: () ->
    @fileupload.setParams(
      authenticity_token : $("meta[name=csrf-token]").attr("content"),
      version_name : "100x100"
    )

  render: () ->
    @$el

  chose_upload: () ->
    @$("input:file").click()

class VideoUpload extends Backbone.View
  tagName: "a",
  className: "btn btn-mini",
  template: "<i class='icon-film'></i>"
  events: {

  },

  initialize: () ->
    @$el = $(@el)
    @$el.html(@template)

  render: () ->
    @$el

class AttachmentUpload extends Backbone.View
  initialize: (options) ->
    _.extend(@, options)

    @$el = $(@el).addClass("attachment_uploader")
    @$el.append("<div class='upload_nav' />")
    @$el.append("<div class='upload_preview' />")
    @$preview_el = @$(".upload_preview")
    @$nav_el = @$(".upload_nav")

    image_upload_view = new ImageUpload(
      remote: @remote,
      preview_el: @$preview_el)

    @$nav_el.append(image_upload_view.render())

root.AttachmentUpload = AttachmentUpload