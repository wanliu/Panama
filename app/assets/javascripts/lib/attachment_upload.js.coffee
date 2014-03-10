# author : huxinghai
# describe : 商品ajax上传

#= require jquery
#= require lib/underscore
#= require backbone
#= require ./fileuploader

#
# new AttachmentUpload({
#   el: $("ul"),
#   //初始化数据
#   data: init_data,
#   //是否有默认图片设置
#   default_enabled: false,
#   //限制最大只能上传多少张
#   limit: 5,
#   params: {
#     //远程url
#     url_upload: "/attachment",
#     //空图的默认图片
#     default_img_url: "/assets/default.jpg",
#     //模板
#     template: ""
#     //预览图片大小
#     version_name: "100x100",
#     //提交到服务器的键值
#     input_name: "attachment[ids]",
#     //默认图片的键值，当default_enabled关闭的时候这个不用设置
#     default_input_name: "default_img[id]"
#   }
# })


root = (window || @)

class Attachment extends Backbone.Model

class AttachmentList extends Backbone.Collection
    model : Attachment

class AttachmentView extends Backbone.View
    tagName: "li"
    default_img_class: "default_img"
    events: {
      "mouseout" : "hide_nav_meun",
      "mouseover" : "show_nav_meun",
      "click .default-img" : "_set_default_img",
      "click .delete-img" : "delete_img"
    }

    default_params : {

      #上传url
      url_upload: "",

      #默认图片url
      default_img_url: "",

      #模板
      template: "",

      #预览图片版本
      version_name: "100X100",

      #提交文本名
      input_name: "",

      #默认图片的文本名称
      default_input_name: ""
    }

    initialize : () ->
      @model = @options.model
      $.extend(@default_params, @options.params)

      @$el = $(@el)

      @init_template()
      @model.bind("remove_view", @remove_view, @)
      @model.bind("set_default_attr", _.bind(@set_default_attr, @))
      @model.bind("set_value_attr", _.bind(@set_value_attr, @))

    init_template : () ->
      @$el.html(@default_params.template)
      @init_element()

    init_element : () ->
      @upload_panle = @$(".attachment-upload")
      @hidden_input = @$("input[type=hidden]")
      @preview = @$("img.attachable-preview")
      @bottom_meun = @$(".nav-panle")
      @attachable = @$(".attachable")
      @progress_panle = @$(".progress-panle")

      @init_file_upload()
      @init_data()

    change_style: () ->
      @$(".qq-upload-button").css(
        overflow: 'visible',
        position: 'static'
      )

    init_data: () ->
      @hidden_input.val(@model.id)
      if @is_default_img()
        @set_default_attr()
      else
        @set_value_attr()

      @preview.attr("src", @model.get("url"))

    render : () ->
      @$el

    init_file_upload : () ->
      @fileupload = new qq.FileUploader({
        element: @upload_panle[0],
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
        sizeLimit: 1048576, # max size: 1MB
        minSizeLimit: 0, # min size
        multiple: false,
        action: "#{@default_params.url_upload}/upload",
        inputName: "attachable",
        cancelButtonText: "取消上传",
        uploadButtonText: '',
        onComplete: _.bind(@complete_callback, @),
        onSubmit: _.bind(@submit_before_callback, @),
        onProgress: _.bind(@progress_callback, @),
        messages: @messages()
      })

    messages: () ->
      {
        typeError: "请选择正确的{file}头像图片，只支持{extensions}图片",
        sizeError: "{file}头像图片，超过{sizeLimit}了！",
        unsupportedError: "不支持该类型的文件，请从文件管理器中拖放文件"
      }

    progress_callback: (id, filename, loaded, total) ->
      bar = @progress_panle.find(">.progress>.bar")
      if bar.length > 0
        bar.width("#{(loaded/total) * 100}%")

    submit_before_callback: (id, filename) ->
      @progress_panle.show();
      @fileupload.setParams(
        authenticity_token: $("meta[name=csrf-token]").attr("content"),
        version_name: this.default_params.version_name
      )

    complete_callback : (id, filename, data) ->
      return unless data.success
      @progress_panle.hide();
      info = data.attachment
      #空图框时，添加新的空图框
      @trigger("add_blank_preview") if @is_blank_img()
      @model.set(info)
      @init_data()
      @change_style();

    hide_nav_meun : () ->
      @bottom_meun.hide()

    show_nav_meun : () ->
      return if @is_blank_img()
      @switch_delete_meun()
      @bottom_meun.show()

    _set_default_img : () ->
      @trigger("clear_blank_default")
      @set_default_attr()

    switch_delete_meun : () ->
      default_el = @bottom_meun.find(".default-img")
      if @is_default_img() then default_el.hide()  else default_el.show()

    is_default_img : () ->
      @attachable.hasClass(@default_img_class)

    is_blank_img : () ->
      @model.id is "" || not @model.id?


    delete_img : () ->
      @model.destroy(
        url : "#{@default_params.url_upload}/#{@hidden_input.val()}",
        success : (model, data) =>
          if @is_default_img()
            @trigger("default_first_img")

          @$el.remove()
      )

    set_value_attr : () ->
      @attachable.removeClass(@default_img_class)
      if @hidden_input.val() is ""
        @hidden_input.removeAttr("name")
      else
        @hidden_input.attr("name", "#{@default_params.input_name}[#{@model.id}]")

    set_default_attr : () ->
      @attachable.addClass(@default_img_class)
      @hidden_input.attr("name", "#{@default_params.default_input_name}")

    remove_view: () ->
      @remove()


class root.AttachmentUpload extends Backbone.View
    data: []
    default_enabled: true  #开启默认图片选择
    limit: 10              #最多上传数量
    params: {

    }
    initialize : () ->
      _.extend(@, @options)
      @$el = $(@el)
      @attachment_list = new AttachmentList
      @attachment_list.bind("add", @add_one, @)

      _.each(@data, (attachment)=>
        @attachment_list.add(attachment)
      )
      @add_blank_preview()
      @default_choose_img(@get_default_model())

    add_one : (model) ->
      view = new AttachmentView(
        model: model,
        params: @options.params
      )
      view.bind("default_first_img", _.bind(@default_first_img, @))
      view.bind("clear_blank_default", _.bind(@clear_blank_default, @))
      view.bind("add_blank_preview", _.bind(@add_blank_preview, @))
      @$el.append(view.render())
      setTimeout () =>
        view.change_style()
      , 80

    default_choose_img: (model) ->
      if @default_enabled
        model.trigger("set_default_attr")

    default_first_img: (model) ->
      @default_choose_img(@attachment_list.models[0])

    add_blank_preview: () ->
      if @limit > @attachment_list.length
        @attachment_list.add( url : @options.params.default_img_url)

    clear_blank_default : () ->
      @attachment_list.each (model) ->  model.trigger("set_value_attr")

    get_default_model : () ->
      temp = @attachment_list.models[0]
      @attachment_list.each (model) ->
        temp = model if model.get("default_state")?
      temp
      
    destroy_all: () ->
      @attachment_list.each (model) ->
        model.trigger("remove_view")
