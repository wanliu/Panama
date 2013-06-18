#encoding: utf-8
#后台管理上传功能
class AplumInput
  include Formtastic::Inputs::Base

  def to_html
    main_template
  end

  private
  def main_template
    collection = options[:collection] || []
    upload_url = options[:upload_url]
    img_version = options[:img_version]
    default_url = options[:default_url] || template.default_img_url(img_version)
    el_id = rand.to_s.gsub(".", "")

    output = ActiveSupport::SafeBuffer.new
    output << template.content_tag(:li) do
      <<-HTML
        <label class='label'>图片</label>
        <div id="#{el_id}"></div>
      HTML
    end

    output << template.javascript_tag(<<-JAVASCRIPT
      new ProductUpload({
        el: document.getElementById("#{el_id}"),
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
    JAVASCRIPT
    )

    output
  end

  def upload_template
    <<-HTML
    <div class="attachable">
      <img  class="img-rounded attachable-preview" />
      <input type="hidden" />
      <div class="attachment-upload"></div>
      <div class="operation-panle">
        <a href="javascript:void(0)" class="delete-img">删除</a>
        <a href="javascript:void(0)" class="default-index-img">设为主图</a>
      </div>
      <div class="progress-panle"></div>
    </div>
    HTML
  end
end