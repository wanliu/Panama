class DependSelectInput < SimpleForm::Inputs::CollectionSelectInput

  def input
    isif = reflection.blank?
    strID = isif ? "" : "_id"
    children = input_options[:children].blank? ? "" : children_dom_id
    url = input_options[:collection_url] || ""
    @collection = input_options[:collection] ?  collection :  []
    label_method, value_method = detect_collection_methods
    
    input_html_options[:class].push(dom_id) 
    @builder.collection_select(
      attribute_name, @collection, value_method, label_method,
      input_options, input_html_options
    ) +
    <<-JAVASCRIPT
      <SCRIPT type='text/javascript'>
      	require(['jquery', 'lib/depend_select'], function($, DependSelectView){
            new DependSelectView({el: '.#{dom_id}', children: '#{children}',url: '#{url}'})
        });
      </SCRIPT>
    JAVASCRIPT
    .html_safe
  end

  def field_name 
  	"#{lookup_model_names.join("_")}_#{reflection_or_attribute_name}"
  end

  def children_name
    "#{lookup_model_names.join("_")}_#{input_options[:children]}"
  end

  def dom_id
    return field_name if input_options[:object].blank?
    @builder.template.dom_id(input_options[:object], field_name)
  end

  def children_dom_id 
    return children_name if input_options[:object].blank? 
    @builder.template.dom_id(input_options[:object], children_name)
  end
end
