class ChosenInput < SimpleForm::Inputs::CollectionSelectInput

  def input
  	# "$ #{@builder.text_field(attribute_name, input_html_options)}".html_safe   collection 
  	label_method, value_method = detect_collection_methods
    @builder.collection_select(
      attribute_name, ['',''], value_method, label_method,
      input_options, input_html_options
    ) +
    <<-JAVASCRIPT
    <SCRIPT type='text/javascript'>
    	$("##{field_name}").chosenEx({remote: {remote_url: '#{input_html_options[:remote_url]}'}})
    </SCRIPT>
    JAVASCRIPT
    .html_safe
  end

  def field_name 
  	"#{lookup_model_names.join("_")}_#{reflection_or_attribute_name}"
  end
end
