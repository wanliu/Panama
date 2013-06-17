class ColumnviewInput < SimpleForm::Inputs::Base

  def input
    element_id = input_options[:id] || rand.to_s.split(".").last
    category = input_options[:value]
    if category.nil?
        @builder.hidden_field(attribute_name, input_html_options.merge(:value => input_options[:value] ? input_options[:value].id : "" ))
    end
    <<-HTML
        #{template.build_menu(input_options[:root], element_id)}
        <script type="text/javascript">
        if("" != '#{category}' ){
          $("##{element_id}").columnview({
              length: '#{category.ancestry_depth}',
              ancestry: '#{category.ancestry}',
              category_id: '#{category.id}',
              ihid: '#{field_name}',
              ihname: '#{@builder.object.class.name.underscore}[#{attribute_name}]'
          });
        } else {
          $("##{element_id}").columnview({
            length: '',
            ancestry: '',
            category_id: '',
            ihid: '',
            ihname: '',
            selector : function(data, current_data){
              $("input:hidden[name='#{@builder.object.class.name.underscore}[#{attribute_name}]']").val(current_data.id)
            }
          })
        }
        </script>
    HTML
    .html_safe
  end

  def field_name
    "#{lookup_model_names.join("_")}_#{reflection_or_attribute_name}"
  end
end