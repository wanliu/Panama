# author : huxinghai
# describe : 产品ajax上传 

define(["jquery", "backbone", "fileuploader", "exports"], ($, Backbone, qq, exports) ->
    
    class exports.ProductUpload extends Backbone.View

        initialize : () ->
            _.extend(@, @options)
            @init_up_file()

        render : () ->

        init_up_file : () ->
            @fileupload = new qq.FileUploader({
                element : @el[0],
                allowedExtensions : ['jpg', 'jpeg', 'png', 'gif'],
                sizeLimit : 1048576, # max size: 1MB
                minSizeLimit : 0, # min size
                debug : true,
                multiple : true,
                action : '/shops/50fcdf4adc86738e6f000002/admins/products/product_upload',
                inputName : "preview",
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

    exports
)
