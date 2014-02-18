#= require lib/underscore
#= require lib/fileuploader
#= require backbone
root = window || @

class root.Upload extends Backbone.View
  template: '
    <div class="qq-uploader">
      <pre class="qq-upload-drop-area">
        <span>{dragText}</span>
      </pre>
      <div class="qq-upload-button btn btn-success" style="width: 85px;">
        <i class="icon-upload icon-white"></i>
        {uploadButtonText}
      </div>
      <ul class="qq-upload-list" style="margin-top: 10px; text-align: center;">
      </ul>
    </div>'

  initialize: () ->
    @current_user = @options.current_user
    @verify_authenticity_token = @options.verify_authenticity_token
    @targets = @options.targets
    @action = @options.action
    _(@targets).each (target) =>
      element = target.el
      inputName = target.input_name
      @init_avatar(element, inputName)
      @$avatar = element.find("img.normal_picture")
      @show_avatar(target.photo)
      
  init_avatar: (element, inputName) ->
    fileupload = new qq.FileUploader({
      element: element.find("div.upload_user_avatar")[0],
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
      sizeLimit: 1048576, 
      minSizeLimit: 0, 
      debug : true,
      multiple: false,
      action: @action+"#{@current_user.id}?field_name=#{inputName}",
      inputName: inputName,
      template: @template,
      cancelButtonText: '取消上传',
      uploadButtonText: '上传图片',
      dragText: '拖放到这里上传图片',
      onComplete: (id, filename, data) =>
        element.find("ul.qq-upload-list").hide();
        @$avatar = element.find("img.normal_picture")
        if data.success
          @show_avatar(data.avatar_filename)  
          element.find("div.qq-upload-button").show()

      onSubmit : (id, filename) =>
        fileupload.setParams({
          authenticity_token: @verify_authenticity_token
        })

      onProgress: (id, filename, loaded, total) ->
        element.find("div.qq-upload-button").hide()  

      messages: {
        typeError : "请选择正确的{file}图片，只支持{extensions}图片",
        sizeError : "{file}图片，超过{sizeLimit}了！"
      }
    })

  show_avatar: (file) ->
    @$avatar.attr("src", file)

