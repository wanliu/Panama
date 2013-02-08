module Admins::Shops::ProductsHelper

    def picture_and_name(record)        
      content_tag :div, :class => 'btn-group' do                
        imgs = record.attachments.map do | a |
            image_tag(a.file.url("30x30"))
        end

        imgs << image_tag(record.default_attachment.file.url("30x30"))

        imgs.join.html_safe + label_tag(record.name)
      end
    end

    def render_styles
        result = filter_styles.map do |style_group|
            value = style_group.items
            title = style_group.name
            color_span = (title == 'Colours' || title == 'colours') ? true : false
            sub_product_property(title, value, {:class => title.downcase}, :title, color_span)
        end
        result.join('').html_safe
    end

    #区分商品编辑与表单错误返回
    def filter_styles
        @temp_styles || @product.styles
    end

    def filter_attribtues
        filter_styles.map{|style_group| style_group.name}
    end

    def sub_product_property(name, instance_var, html_options={}, method = nil, color_span = nil)
        className = html_options[:class] || ''
        html = marker_and_mq_element
        html << div_open(className, name)

        instance_var.each do |item|
            field = method ? item.send(method) : item
            html << label_open
            html << hidden_title(name, field)
            html << checked(item, name, field)
            html << hidden_value(name, item)
            html << color_special(item) if color_span
            html << label_close(field)
        end
        html << div_close
    end

    # the element for information exchanges between two js view
    def marker_and_mq_element
        "<a class='button trigger-data-filled' href='javascript:void()' style='display:none;'></a>"
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

    def hidden_title(name, field)
        "<input type='hidden' name='style[#{name}][title][]' value='#{field}' >"
    end

    def hidden_value(name, item)
        "<input type='hidden' name='style[#{name}][value][]' value=#{item.value}>"
    end

    def checked(item, name, field)
        "<input class='check_boxes optional' name='style[#{name}][checked][]' type='checkbox' value='#{field}' #{"checked='checked'" if item[:checked] || item['checked']}>"
    end

    def color_special(item)
        "<span style= 'width:13px; height:13px; background-color: #{item.value}; display: inline-block; '></span>"
    end

    #############################################################################################
    ## fill data to the table created by js,
    ## if the @product isn't new or it's form return for in correct input
    ############################################################################################
    def data_2_talbe
        return if @product.new_record? and @temp_subs.blank?

        subs = @temp_subs || @product.sub_products
        # debugger
        objects = subs.map do |sub|
            filters = ['_id', 'id', 'created_at', 'product_id']
            object = []
            begin
                # temp_subs
                sub.last.each_pair do |k, v|
                    object.push "#{k.to_s} : '#{v}'" if !filters.include?(k)
                end
            rescue
                # sub_products
                sub.attributes.each_pair do |k, v|
                    object.push "#{k.to_s} : '#{v}'" if !filters.include?(k)
                end
            end
            "{" + object.join(',') + "}"
        end

        "require(['lib/data_2_table'], function(data2table){
            var load = new data2table.Data2Table({
                collection : [#{objects.join(',')}]
            })
        })".html_safe
    end
end
