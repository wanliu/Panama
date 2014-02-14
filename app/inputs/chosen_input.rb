class ChosenInput < SimpleForm::Inputs::CollectionSelectInput

  def input
  	# "$ #{@builder.text_field(attribute_name, input_html_options)}".html_safe   collection
    @isif = reflection.blank?
    @strID = @isif ? "" : "_id"
    remote_key = input_options[:remote_key] || "name"
    remote_value = input_options[:remote_value] || "id"
    param_name = input_options[:param_name] || "q"
    label_method, value_method = detect_collection_methods
    input_html_options[:class].push(dom_id)

    @builder.collection_select(
      attribute_name, collection, value_method, label_method,
      input_options, input_html_options
    )+
    <<-JAVASCRIPT
    <SCRIPT type='text/javascript'>
        $(document).ready(function(){
          $(".#{dom_id}").chosenEx({
            remote: {
              url: '#{input_options[:url]}',
              remote_key: #{remote_key.inspect},
              remote_value: #{remote_value.inspect},
              param_name: #{param_name.inspect}
            }
          });
        })
    </SCRIPT>
    JAVASCRIPT
    .html_safe
  end

  def field_name
  	"#{lookup_model_names.join("_")}_#{reflection_or_attribute_name}"
  end

  def dom_id
    return field_name if input_options[:object].blank?
    @builder.template.dom_id(input_options[:object], field_name)
  end
end
