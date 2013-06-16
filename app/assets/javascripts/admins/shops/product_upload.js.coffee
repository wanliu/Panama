# author : huxinghai
# describe : 产品ajax上传

#= require jquery
#= require backbone
#= require lib/fileuploader

root = (window || @)

class Attachment extends Backbone.Model

class AttachmentList extends Backbone.Collection
    model : Attachment

class ProductAttachmentUpload extends Backbone.View
    tagName : "li"
    default_img_class : "default_img"
    events : {
        "click img.attachable-preview" : 'upload',
        "mouseout" : "hide_bottom_meun",
        "mouseover" : "show_bottom_meun",
        "click .default-index-img" : "_set_default_index_img",
        "click .delete-img" : "delete_img"
    }

    default_params : {

        #上传url
        url_upload : "",

        #默认图片url
        default_img_url : "",

        #模板
        template : "",

        #预览图片版本
        version_name : "100X100",

        #提交文本名
        input_name : "",

        #默认图片的文本名称
        default_input_name : ""
    }

    initialize : () ->
        @model = @.options.model
        $.extend(@.default_params, @.options.params)

        @el = $(@el)

        @init_template()
        @model.bind("set_default_attr", _.bind(@set_default_attr, @))
        @model.bind("set_value_attr", _.bind(@set_value_attr, @))

    upload : () ->
        @file_input.click()

    init_template : () ->
        @$el.html(@default_params.template)
        @init_element()

    init_element : () ->
        @attachment_upload_panle = @$(".attachment-upload")
        @hidden_input = @$("input[type=hidden]")
        @img = @$("img.attachable-preview")
        @bottom_meun = @$(".operation-panle")
        @attachable = @$(".attachable")
        @progress_panle_list = @$(".progress-panle").find("ul.list")
        @init_up_file()
        @file_input = @$("input[type=file]")

        @init_element_data()

    init_element_data: () ->
        @img.attr("src", @model.get("url"))
        @hidden_input.val(@model.id)
        if @is_default_index_img() then @set_default_attr() else @set_value_attr()

    render : () ->
        @$el

    init_up_file : () ->
        @fileupload = new qq.FileUploader({
            element : @attachment_upload_panle[0],
            allowedExtensions : ['jpg', 'jpeg', 'png', 'gif'],
            sizeLimit : 1048576, # max size: 1MB
            minSizeLimit : 0, # min size
            debug : true,
            multiple : false,
            action : "#{@default_params.url_upload}/upload",
            inputName : "attachable",
            cancelButtonText : "取消上传",
            uploadButtonText : '<i class="icon-upload icon-white"></i> 上传头像',
            onComplete : _.bind(@complete_callback, @),
            onSubmit : _.bind(@submit_before_callback, @),
            messages : @messages()
        })

    file_upload_button_template : () ->
        """
        <div class="qq-uploader">
            <pre class="qq-upload-drop-area"><span>{dragZoneText}</span></pre>
            <div class="qq-upload-button btn btn-success" style="width: auto;">{uploadButtonText}</div>
            <ul class="qq-upload-list" style="margin-top: 10px; text-align: center;"></ul>
        </div>
        """

    messages : () ->
        {
            typeError : "请选择正确的{file}头像图片，只支持{extensions}图片",
            sizeError : "{file}头像图片，超过{sizeLimit}了！"
        }

    submit_before_callback : (id, filename) ->
        @fileupload.setParams(
            authenticity_token : $("meta[name=csrf-token]").attr("content"),
            version_name : this.default_params.version_name
        )

    complete_callback : (id, filename, data) ->
        return unless data.success
        info = JSON.parse(data.attachment)
        #空图框时，添加新的空图框
        @trigger("add_blank_product_attachment") if @is_blank_img()
        @model.set(info)
        @init_element_data()

    hide_bottom_meun : () ->
        @bottom_meun.hide()

    show_bottom_meun : () ->
        return if @is_blank_img()
        @switch_delete_meun()
        @bottom_meun.show()

    _set_default_index_img : () ->
        @trigger("clear_blank_default")
        @set_default_attr()

    switch_delete_meun : () ->
        default_el = @bottom_meun.find(".default-index-img")
        if @is_default_index_img() then default_el.hide()  else default_el.show()

    is_default_index_img : () ->
        @attachable.hasClass(@default_img_class)

    is_blank_img : () ->
        @model.id is "" || not @model.id?


    delete_img : () ->
        @model.destroy(
            url : "#{@default_params.url_upload}/#{@hidden_input.val()}",
            success : (model, data) =>
                if @is_default_index_img()
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


class root.ProductUpload extends Backbone.View

    initialize : () ->
        _.extend(@, @options)
        @$el = $(@el)
        @attachment_list = new AttachmentList
        @attachment_list.bind("add", @add_one, @)

        $.each(@data, (i, attachment)=>
            @attachment_list.add(attachment)
        )
        @add_blank_product_attachment()
        @default_choose_img(@get_default_model())

    add_one : (model) ->
        product_attachment = new ProductAttachmentUpload(
            model : model,
            params : @options.params
        )
        product_attachment.bind("default_first_img", _.bind(@default_first_img, @))
        product_attachment.bind("clear_blank_default", _.bind(@clear_blank_default, @))
        product_attachment.bind("add_blank_product_attachment", _.bind(@add_blank_product_attachment, @))
        @$el.append(product_attachment.render())

    default_choose_img: (model) ->
        model.trigger("set_default_attr")

    default_first_img: (model) ->
        @default_choose_img(@attachment_list.models[0])

    add_blank_product_attachment : () ->
        @attachment_list.add( url : @options.params.default_img_url)

    clear_blank_default : () ->
        @attachment_list.each (model) ->  model.trigger("set_value_attr")

    get_default_model : () ->
        temp = @attachment_list.models[0]
        @attachment_list.each((model) ->
            temp = model if model.get("default_state")?
        )
        temp


