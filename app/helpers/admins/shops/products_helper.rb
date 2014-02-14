# encoding: utf-8
module Admins::Shops::ProductsHelper
    include ActionController::RecordIdentifier

    def picture_and_name(record)
      content_tag :div, :class => 'btn-group' do
        imgs = record.attachments.map do | a |
            image_tag(a.file.url("30x30"))
        end

        imgs << image_tag(record.default_attachment.file.url("30x30")) if record.default_attachment

        imgs.join.html_safe + label_tag(record.name)
      end
    end

    # def render_styles(styles = filter_styles)
    #     styles.map { |style| render_style(style) }.join('').html_safe
    # end

    # def render_style(style)
    #     items = style.items
    #     title = style.name
    #     color_span = (title == 'Colours' || title == 'colours')
    #     sub_product_property(title, items, {:class => title.downcase}, :title, color_span)
    # end

    # #区分商品编辑与表单错误返回
    # def filter_styles
    #     @temp_styles || @product.styles || {}
    # end

    # def filter_attribtues
    #     filter_styles.map{|style_group| style_group.name}
    # end

    # def sub_product_property(name, items, html_options = {}, method = nil, color_span = nil)
    #     class_name = html_options[:class] || ''
    #     html = marker_element
    #     html << div_open(class_name, name)

    #     items.each_with_index do |item, index|
    #         append_content(item, index, html, name, method, color_span)
    #     end
    #     html << div_close
    # end

    # def append_content(item, index, html, name, method, color_span)
    #     field = method ? item.send(method) : item
    #     html << label_open
    #     html << hidden_title(name, field, index)
    #     html << checked(item, name, field, index)
    #     html << hidden_value(name, item, index) unless color_span
    #     html << color_special(name, item, index) if color_span
    #     html << label_close(field)
    # end

    # # the element for information exchanges between two js view
    # def marker_element
    #     "<a class='button trigger-data-filled' href='javascript:void()' style='display:none;'></a>"
    # end

    # def div_open(className, name)
    #     "<div class= 'control-group check_boxes optional #{className}' >
    #         <label class='check_boxes optional control-label'>#{name}</label>
    #             <div class='controls'>"
    # end

    # def div_close
    #     "</div></div>"
    # end

    # def label_open
    #     "<label class='checkbox'>"
    # end

    # def label_close(field)
    #     "<span class='name'>#{field}</span></label>"
    # end

    # def hidden_title(name, field, index)
    #     "<input type='hidden' name='style[#{name}][#{index}][title]' value='#{field}' >"
    # end

    # def hidden_value(name, item, index)
    #     "<input type='hidden' name='style[#{name}][#{index}][value]' value=#{item.value}>"
    # end

    # def checked(item, name, field, index)
    #     "<input class='check_boxes optional' name='style[#{name}][#{index}][checked]' type='checkbox' value='#{field}' #{"checked='checked'" if item[:checked] || item['checked']}>"
    # end

    # def color_special(name, item, index)
    #     "<div class='input-append color' data-color='#{item.value}' data-color-format='rgb'>
    #       <input type='hidden' class='span2' name='style[#{name}][#{index}][value]' value=#{item.value}>
    #       <span class='add-on' style='border:none; height: auto; background-color: transparent;'>
    #         <i style='background-color: #{item.value}'></i>
    #       </span>
    #     </div>"
    # end


    # ## fill data to the table created by js,
    # ## if the @product isn't new or it's form return for in correct input
    # def data_2_talbe
    #     return if @product.new_record? && @temp_subs.blank?

    #     subs = @temp_subs || @product.sub_products
    #     # debugger
    #     objects = subs.map do |sub|
    #         filters = ['_id', 'id', 'created_at', 'product_id']
    #         object = []
    #         begin
    #             # temp_subs
    #             sub.last.each_pair do |k, v|
    #                 object.push "#{k.to_s} : '#{v}'" unless filters.include?(k)
    #             end
    #         rescue
    #             # sub_products
    #             sub.styles.each_pair do |k, v|
    #                 object.push "#{k.to_s} : '#{v}'" unless filters.include?(k)
    #             end
    #         end
    #         "{" + object.join(',') + "}"
    #     end

    #     render_data_table(objects)
    # end

    def render_prices_table(columns)
        javascript_tag <<-JAVASCRIPT

            var bander = new TableBander({
                // els : [$('div.colours'), $('div.sizes')],
                els    : $("form div[price_attrib*=prices]").map(function(i, ele) { return $(ele); }),
                fields : [{title: '价格', value: 'price'}, {title: '数量', value: 'quantity'}],
                depth  : #{columns.to_json}
            });


            #{generate_prices_table}

        JAVASCRIPT
        .html_safe
    end

    def generate_prices_table
        pis = PropertyItem
            .joins(:property, :product_prices)
            .select(['product_prices.id', 'property_items.property_id', 'property_items.value', 'properties.name', 'product_prices.price'])
            .where("product_prices.product_id = ?", @product.id)
            .group_by { |pi| pi.id }
            .map { |k, ary| Hash['price', ary.first[:price].to_s, *(ary.map { |item| [item.name, item.value] }.flatten) ] }
        render_data_table(pis)
    end

    def render_data_table(objects)
        """
            var load = new Data2Table({
                collection : #{objects.to_json}
            })
        """.html_safe
    end

    def property_palette(form, field)
        field = field.to_sym
        content_tag :div, :price_attrib => "prices_#{field}" do
            form.input field,
                       :as => :check_boxes,
                       :collection => @product.properties[field].try(:items) || [],
                       :value_method => :value,
                       :checked => @product.property_items[field].map { |item| item.value }

        end
    end

    def property_selector(form, field)
        field = field.to_sym
        content_tag :div, :price_attrib => "prices_#{field}" do
            form.input field,
                       :as => :radio_buttons,
                       :collection => @item.property_items[field],
                       :value_method => :value

        end
    end

    def propoerty_prices(form, *args)
        form.input :price_definition, :as => :hidden, :input_html => { :value => args.join(',') }
    end

    def price_option_rule(price)
        hash = {:id => price.id,
                :price => price.price }
        price.items.each do |item|
            hash[item.property.name] = item.value
        end
        hash
    end

end
