#encoding: utf-8
#后台管理上传功能
class AplumInput
  include Formtastic::Inputs::Base

  def to_html
    collection = options[:collection] || []
    upload_url = options[:upload_url] || template.attachments_path
    img_version = options[:img_version]
    default_url = options[:default_url] || template.default_img_url(img_version)
    el_id = rand.to_s.gsub(".", "")

    input_wrapping do
      output = ActiveSupport::SafeBuffer.new
      output << template.content_tag(:li) do
        template.content_tag(:label, "图片", class: "label") +
        template.content_tag(:div) do
          template.content_tag(:ul,nil, id: el_id, class: "attachment-list")
        end
      end

      output << template.javascript_tag(<<-JAVASCRIPT
        $(document).ready(function(){
          new AttachmentUpload({
            el: $("##{el_id}"),
            data: #{collection.to_json},
            params: {
              url_upload: "#{upload_url}" ,
              default_img_url: "#{default_url}",
              template: '#{template.j(upload_template)}',
              version_name: "#{img_version}",
              input_name: "product[attachment_ids]",
              default_input_name: "product[default_attachment_id]"
            }
          })
        })
      JAVASCRIPT
      )
      output
    end
  end

  private
  def upload_template
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
        <img src='/assets/loading.gif' />
      </div>
    </div>
    HTML
  end
end