//author : huxinghai
//describe : 扩展fileuploader.js上传功能
//exemple :
//      file_upload = new qq.FileUploader{
//          ...
//          autoUpload : false  // 禁止自动上传,默认true自动上传
//      }
//
//      //调用上传
//      $("#button_id").click(function(){
//          file_upload.submitUpload()
//      })
//
(function(){
  var oldUploadButton = qq.UploadButton.prototype._createInput
  qq.UploadButton.prototype._createInput = function(){
    var input = oldUploadButton.apply(this)
    if(!this._options.autoUpload)
        this._options.onChange = function(){}
    return input
  }
  qq.FileUploader.prototype.submitUpload = function(){
    this._onInputChange(this._button._input)
  }
  var oldFileUploader = qq.FileUploader
  qq.FileUploader = function(options){
    file_uploader = new oldFileUploader(options)
    file_uploader._button._options.autoUpload = true
    if(options.hasOwnProperty("autoUpload")){
        file_uploader._button._options.autoUpload = options.autoUpload
    }
    return file_uploader
  }
})()