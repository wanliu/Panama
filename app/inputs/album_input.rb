#encoding: utf-8

class AlbumInput < SimpleForm::Inputs::CollectionSelectInput
  include ActionView::Helpers::JavaScriptHelper

  def input
    output = ActiveSupport::SafeBuffer.new
    output << photo_generate
    output
  end

  def photo_generate
    el_id = SecureRandom.hex
    img_version = input_options[:img_version] || "100x100"

    output = ActiveSupport::SafeBuffer.new
    output << template.content_tag(:ul, nil, :class => "attachment-list", :id => el_id)
    output << template.javascript_tag(<<-JAVASCRIPT
      new AttachmentUpload({
          el: document.getElementById("#{el_id}"),
          data: #{collection.to_json},
          params: {
            url_upload: "#{input_options[:upload_url]}" ,
            default_img_url: "#{input_options[:default_url] || template.default_img_url(img_version) }",
            template: '#{j(photo_template)}',
            version_name: "#{img_version}",
            input_name: "product[attachment_ids]",
            default_input_name: "product[default_attachment_id]",
            limit: 5
          }
        })
    JAVASCRIPT
    )

    output
  end

  def photo_template
    <<-HTML
    <div class="attachable">
      <img  class="img-rounded attachable-preview" />
      <input type="hidden" />
      <div class="attachment-upload"></div>
      <div class="nav-panle">
        <a href="javascript:void(0)" class="delete-img">删除</a>
        <a href="javascript:void(0)" class="default-index-img">设为主图</a>
      </div>
      <div class="progress-panle">
        <div class="progress progress-mini progress-success">
          <div class="bar" style="width: 0%"></div>
        </div>
      </div>
    </div>
    HTML
  end
end