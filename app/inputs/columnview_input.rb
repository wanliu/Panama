#encoding : utf-8
class ColumnviewInput < SimpleForm::Inputs::Base

  def input
    element_id = input_options[:id] || rand.to_s.split(".").last 
    <<-HTML
        #{template.build_menu(input_options[:collection], element_id)} 
        #{@builder.hidden_field(attribute_name, input_html_options)}
        <script type="text/javascript">
          require(["jquery_columnview"], function($){            
            $("##{element_id}").columnview({
                selector : function(data, current_data){                   
                  $("input:hidden[name='#{@builder.object.class.name.underscore}[#{attribute_name}]']").val(current_data.id)                                                           
                }
            });  
          })                
        </script>
    HTML
    .html_safe
  end



  def field_name
    "#{lookup_model_names.join("_")}_#{reflection_or_attribute_name}"
  end 
end