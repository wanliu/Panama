class AlbumInput < SimpleForm::Inputs::CollectionSelectInput

  def input
    output = ActiveSupport::SafeBuffer.new

    collection.each do |photo|
      output << photograph(photo)
    end
    output << photograph(Attachment.new)
    output
  end

  def photograph(photo)
    output = ActiveSupport::SafeBuffer.new
    output << template.image_tag(photo.file.url("100x100")) 
    output << template.content_tag(:div, nil, :class => :uploader, :id => photo.id)
    output << template.javascript_tag(<<-JAVASCRIPT
      require(["jquery", "fileuploader"], function($, qq){
        var uploader = new qq.FileUploader({
          // pass the dom node (ex. $(selector)[0] for jQuery users)
          element: document.getElementById('#{photo.id}'),
          // path to sevrer-side upload script
          action: #{input_options[:upload_url].inspect}, 
          complete: function() {

          }
        }); 
      });
    JAVASCRIPT
    )
    @builder.simple_fields_for(:attachments, photo) do |f|
      output << f.input(:file_filename)
      output << f.check_box(:_destroy)
    end
    output
  end
end