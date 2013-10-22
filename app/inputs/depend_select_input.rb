class DependSelectInput < SimpleForm::Inputs::CollectionSelectInput

  def input
    isif = reflection.blank?
    strID = isif ? "" : "_id"
    url = input_options[:collection_url] || ""

    label_method, value_method = detect_collection_methods
    input_html_options[:class].push(dom_id)
    $form_id = (input_html_options[:form_id].blank? ? "" : "[form_id=#{input_html_options[:form_id]}]")
    $children = (children.blank? ? "" : "#{$form_id}.#{children}")

    @builder.collection_select(
      attribute_name, collection, value_method, label_method,
      input_options, input_html_options
    ) + <<-JAVASCRIPT
      <SCRIPT type='text/javascript'>
        $(function(){
          new DependSelectView({
            el: "#{$form_id}.#{dom_id}",
            children: "#{$children}",
            url: "#{url}"
          })
        })
      </SCRIPT>
    JAVASCRIPT
    .html_safe
  end

  def children
    input_options[:children].blank? ? "" : children_dom_id
  end

  def collection
    collection = options[:collection] || self.class.boolean_collection
    @collection ||= if options[:collection]
                      collection.respond_to?(:call) ? collection.call : collection.to_a
                    else
                      target_object.try(:children) || []
                    end
  end

  def target_object
    object.try(:send, target) if target
  end

  def target
    input_options[:target]
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
