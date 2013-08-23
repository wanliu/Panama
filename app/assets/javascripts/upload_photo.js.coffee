#= require lib/underscore
#= require lib/fileuploader
#= require backbone
root = window || @
class root.Upload extends Backbone.View

    initialize: () ->
      @current_user = @options.current_user
      @verify_authenticity_token = @options.verify_authenticity_token
      # default_avatar : "/assets/default_avatar.png"
      # avatar_path : "uploads/user/avatar/"
      @$el = $(@el)
      # @$el.html(this.template())   
      @$avatar = @$("img.normal_picture")
      @init_avatar()
      @show_avatar(@current_user.avatar)

    init_avatar: (options) ->                 
      fileupload = new qq.FileUploader({
        element: @$("div.upload_user_avatar")[0],
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
        sizeLimit: 1048576, 
        minSizeLimit: 0, 
        debug : true,
        multiple: false,
        action: "/accounts/registrations/upload_avatar/#{@current_user.id}",
        inputName: "avatar",
        template: '<div class="qq-uploader">' +
        '<pre class="qq-upload-drop-area"><span>{dragZoneText}</span></pre>' +
        '<div class="qq-upload-button btn btn-success" style="width: auto;">{uploadButtonText}</div>' +
        '<ul class="qq-upload-list" style="margin-top: 10px; text-align: center;"></ul>' +
        '</div>',
        cancelButtonText: "取消上传",
        uploadButtonText: '<i class="icon-upload icon-white"></i> 上传头像',        
        onComplete: (id, filename, data) =>
          @$("ul.qq-upload-list").hide();                    
          if data.success                                           
            @show_avatar(data.avatar_filename)      

        onSubmit : (id, filename) =>
          fileupload.setParams({
            authenticity_token: @verify_authenticity_token
          })

        messages : {
          typeError : "请选择正确的{file}头像图片，只支持{extensions}图片",
          sizeError : "{file}头像图片，超过{sizeLimit}了！"
        }
      })

    show_avatar: (file) ->
      @$avatar.attr("src", file)