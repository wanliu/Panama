class AlbumInput < SimpleForm::Inputs::CollectionSelectInput

  def input
    debugger
    output = ActiveSupport::SafeBuffer.new    
    output << photo_generate
    # collection.each do |photo|
    #   output << photograph(photo)
    # end
    # output << photograph(Attachment.new)    
    output
  end

  def photo_generate    
    img_version = input_options[:img_version] || "100x100"
    output = ActiveSupport::SafeBuffer.new
    output << template.content_tag(:div, nil, :class => "attachment-list", :id => photo.id)
    output << template.javascript_tag(<<-JAVASCRIPT
        require(["admins/shops/product_upload", "models/attachment"], function(view, models){
          new view.ProductUpload({
            el : document.getElementById("#{photo.id}"),
            data : #{raw collection.to_json },   
            params : {            
              url_upload : "#{input_options[:upload_url]}" ,
              default_img_url : "#{input_options[:default_url] || photo.file.default_url(img_version) }",                       
              template : "#{photo_template}",
              version_name : "#{img_version}",
              input_name : "product[attachment_ids]"
            }
          })
        })
    JAVASCRIPT
    )  

    output
  end

  def photo_template
    <<-HTML
      <div class='attachable'>   
        <img src='' class='img-rounded attachable-preview' />
        <input type='hidden' name='' value='' />
        <div class="attachment-upload"></div>

        <div class='operation-panle' >
            <a href='javascript:void(0)' class='delete-img'>删除</a>
            <a href='javascript:void(0)' class='default-index-img'>设为主图</a>
        </div>
        <div class='progress-panle'>
        </div>
    </div>
    HTML
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
    @builder.simple_fields_for(:attachments, photo) do | f |
      output << f.input(:file_filename)      
    end
    output
  end
end