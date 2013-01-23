# author : huxinghai
# describe : 产品ajax上传 

define(["jquery", "backbone", "fileuploader", "exports"], ($, Backbone, qq, exports) ->
    
    class ProductAttachmentUpload extends Backbone.View

        events : {
            "click img.attachable-preview" : 'upload',
            "mouseout" : "hide_bottom_meun",
            "mouseover" : "show_bottom_meun",
            "click .default-index-img" : "_set_default_index_img",
            "click .delete-img" : "delete_img"
        }

        initialize : () ->
            $.extend(this, this.options)

            @attachment_upload_panle = @$(".attachment-upload")
            @init_up_file()
            @file_input = @$("input[type=file]") 
            @hidden_input = @$("input[type=hidden]")
            @img = @$("img.attachable-preview")   
            @bottom_meun = @$(".focus-panle")

        upload : () ->
            @file_input.click()

        init_up_file : () ->            
            @fileupload = new qq.FileUploader({
                element : @attachment_upload_panle[0],
                allowedExtensions : ['jpg', 'jpeg', 'png', 'gif'],
                sizeLimit : 1048576, # max size: 1MB
                minSizeLimit : 0, # min size
                debug : true,
                multiple : true,
                action : "#{@url_root()}/upload",
                inputName : "attachable",
                template : @template(),
                cancelButtonText : "取消上传",
                uploadButtonText : '<i class="icon-upload icon-white"></i> 上传头像',
                onComplete : _.bind(@complete_callback, @),
                onSubmit : _.bind(@submit_before_callback, @),
                messages : @messages()
            })   

        template : () ->
            '<div class="qq-uploader">' +
              '<pre class="qq-upload-drop-area"><span>{dragZoneText}</span></pre>' +
              '<div class="qq-upload-button btn btn-success" style="width: auto;">{uploadButtonText}</div>' +
              '<ul class="qq-upload-list" style="margin-top: 10px; text-align: center;"></ul>' +
            '</div>'
        messages : () ->
            {
                typeError : "请选择正确的{file}头像图片，只支持{extensions}图片",
                sizeError : "{file}头像图片，超过{sizeLimit}了！"
            }

        submit_before_callback : (id, filename) ->
            @fileupload.setParams(
                authenticity_token : $("meta[name=csrf-token]").attr("content")
            )

        complete_callback : (id, filename, data) ->            
            info = JSON.parse(data.attachment)
            @img.attr("src", info.url)            
            @hidden_input.val(info._id)
            @switch_meun_show_status(false)

        hide_bottom_meun : () ->
            @bottom_meun.hide()

        show_bottom_meun : () -> 
            return if @meun_show_status()            
            @switch_delete_meun()
            @bottom_meun.show()

        _set_default_index_img : () ->            
            @set_default_index_img(@el)

        switch_delete_meun : () ->
            default_el = @bottom_meun.find(".default-index-img")     
            if @el.hasClass(@default_img_class)
                default_el.hide()
            else
                default_el.show();

        meun_show_status : () ->
            @bottom_meun.attr("status") is "true"

        switch_meun_show_status : (status) ->
            @bottom_meun.attr("status", status) 

        delete_img : () ->              
            $.get("#{@url_root()}/destroy/#{@hidden_input.val()}", (data) =>                          
                @switch_meun_show_status(true)
                @img.attr("src", @default_img_url)
            )

        url_root : () ->
            "/shops/#{@shop_id}/admins/attachments"



    
    class exports.ProductUpload extends Backbone.View        
        input_name : "attachment"

        default_img_class : "default_img"

        initialize : () ->
            _.extend(@, @options)

            @attachables = @$("li")     
            $.each(@attachables, (index, elemnt) =>  
                el = $(elemnt).find(".attachable")                                
                new ProductAttachmentUpload( 
                    el : el, 
                    set_default_index_img : _.bind(@set_default_index_img, @),
                    default_img_class : @default_img_class,
                    shop_id : @shop_id,
                    default_img_url : @default_img_url
                )

            )
            @set_default_index_img(@attachables.first().find(".attachable"))

        clear_default_status : () ->
            self = @
            $.each(@attachables, (index, elemnt) ->  
                panle = $(elemnt).find(".attachable")               
                input = panle.find("input[type=hidden]")                
                input.attr("name", "#{self.input_name}[#{input.val()}]")                
                panle.removeClass(self.default_img_class)
            )

        set_default_index_img : (el) ->
            @clear_default_status()
            el.find("input[type=hidden]").attr("name", "#{@input_name}[default]")            
            el.addClass(@default_img_class)

    exports
)
