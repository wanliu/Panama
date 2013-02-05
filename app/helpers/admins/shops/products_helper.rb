module Admins::Shops::ProductsHelper

    def picture_and_name(record)
      content_tag :div, :class => 'btn-group' do
        image_tag(record.preview.url("30x30")) +
        label_tag(record.name)
      end
    end

    def sub_product_property(name, instance_var, html_options={}, method = nil, color_span = nil)
        html_class = html_options[:class] || ''
        html = "<div class= 'control-group check_boxes optional #{html_class}' >
            <label class='check_boxes optional control-label'>#{name}</label>
            <div class='controls'>"
                instance_var.each do |item|
                    field = method ? item.send(method) : item
                    html << "<label class='checkbox'>
                        <input type='hidden' name='product[style][#{name}][name][]' value='#{field}' >
                        <input class='check_boxes optional' name='product[style][#{name}][checked][]' type='checkbox' value='#{field}' #{"checked='checked'" if item[:checked]}>"
                    html << "<span style= 'width:13px; height:13px; background-color: #{item.rgb}; display: inline-block; '></span>
                        <input type='hidden' name='product[style][#{name}][rgb][]' value=#{item.rgb}>" if color_span
                    html << "<span class='name'>#{field}</span></label>"
                end
        html << "</div></div>"
        html.html_safe
    end
end
