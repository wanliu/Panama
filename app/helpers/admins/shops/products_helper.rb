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
                    html << "<label class='checkbox'>
                        <input type='hidden' name='product[#{name}][]' value='#{method ? item.send(method) : item}' >
                        <input class='check_boxes optional' name='product[#{name}_selected][]' type='checkbox' value='#{method ? item.send(method) : item}' >"
                    html << "<span style= 'width:13px; height:13px; background-color: #{item.rgb}; display: inline-block; '></span>" if color_span
                    html << "<span class='name'>#{method ? item.send(method) : item}</span>
                    </label>"
                end
        html << "</div></div>"
        html.html_safe
    end
end
