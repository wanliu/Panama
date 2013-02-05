module Admins::Shops::ProductsHelper

    def picture_and_name(record)
      content_tag :div, :class => 'btn-group' do
        image_tag(record.preview.url("30x30")) +
        label_tag(record.name)
      end
    end

    def render_style
        result = filter_attribtues.map do |key|
            value = @product.style.send(key)

            color_span = (key == 'Colours' || key == 'colours') ? true : false
            sub_product_property(key, value, {:class => key.downcase}, :name, color_span)
        end
        result.join('').html_safe
    end

    def filter_attribtues
        @product.style.attribute_names.select do |key|
            @product.style.send(key).is_a?(Array)
        end
    end

    def sub_product_property(name, instance_var, html_options={}, method = nil, color_span = nil)
        className = html_options[:class] || ''
        html = div_open(className, name)

        instance_var.each do |item|
            field = method ? item.send(method) : item
            html << label_open
            html << hidden_name(name, field)
            html << checked(item, name, field)
            html << color_special(item, name) if color_span
            html << label_close(field)
        end
        html << div_close
        # html.html_safe
    end

    def div_open(className, name)
        "<div class= 'control-group check_boxes optional #{className}' >
            <label class='check_boxes optional control-label'>#{name}</label>
                <div class='controls'>"
    end

    def div_close
        "</div></div>"
    end

    def label_open
        "<label class='checkbox'>"
    end

    def label_close(field)
        "<span class='name'>#{field}</span></label>"
    end

    def hidden_name(name, field)
        "<input type='hidden' name='product[style][#{name}][name][]' value='#{field}' >"
    end

    def checked(item, name, field)
        "<input class='check_boxes optional' name='product[style][#{name}][checked][]' type='checkbox' value='#{field}' #{"checked='checked'" if item[:checked] || item['checked']}>"
    end

    def color_special(item, name)
        "<span style= 'width:13px; height:13px; background-color: #{item.rgb}; display: inline-block; '></span>
        <input type='hidden' name='product[style][#{name}][rgb][]' value=#{item.rgb}>"
    end
end
