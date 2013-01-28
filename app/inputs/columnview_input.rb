#encoding : utf-8
class ColumnviewInput < SimpleForm::Inputs::Base

  def input
    <<-HTML
        #{template.build_menu(@builder.object.send(attribute_name))} 
        #{@builder.hidden_field(attribute_name, input_html_options)}
        <script type="text/javascript">
        $(document).ready(function(){
          $("ul.dropdown-menu").first().columnview({field_name: '#{field_name}'});
          $(".containerobj").hide();
       });
        </script>
    HTML
    .html_safe
  end

  def field_name
    "#{lookup_model_names.join("_")}_#{reflection_or_attribute_name}"
  end 
end