#encoding: utf-8

class AlbumInput < SimpleForm::Inputs::CollectionSelectInput

  def input    
    output = ActiveSupport::SafeBuffer.new    
    output << photo_generate
    output
  end

  def photo_generate
    photo = Attachment.new    
    img_version = input_options[:img_version] || "100x100"
    output = ActiveSupport::SafeBuffer.new
    output << template.content_tag(:ul, nil, :class => "attachment-list", :id => photo.id)
    output << template.javascript_tag(<<-JAVASCRIPT
        require(["admins/shops/product_upload"], function(view, models){          
          new view.ProductUpload({
            el : document.getElementById("#{photo.id}"),
            data : #{collection.to_json},   
            params : {            
              url_upload : "#{input_options[:upload_url]}" ,
              default_img_url : "#{input_options[:default_url] || photo.file.url(img_version) }",                       
              template : '#{photo_template}',
              version_name : "#{img_version}",
              input_name : "product[attachment_ids]",
              default_input_name : "product[default_attachment_id]"
            }
          })          
        })
    JAVASCRIPT
    )  

    output
  end


  def photo_template
    html = ''    
    html << '<div class="attachable">'
    html << '<img  class="img-rounded attachable-preview" />'
    html << '<input type="hidden" />'
    html << '<div class="attachment-upload"></div>'
    html << '<div class="operation-panle">'
    html << '<a href="javascript:void(0)" class="delete-img">删除</a>'
    html << '<a href="javascript:void(0)" class="default-index-img">设为主图</a>'
    html << '</div>'
    html << '<div class="progress-panle"></div>'
    html << '</div>'
    html
  end

end