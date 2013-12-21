class SpinnerInput < SimpleForm::Inputs::Base

  def input
  	input_html_options[:class].push("input-mini spinner-input")
    input_html_options[:panel_class] ||= ""
  	input_html_options[:maxlength] = input_options[:maxlength] || "3"
  	input_html_options[:value] = input_options[:value] || "1"

  	discern_class = "spinner_"+object.class.to_s+"_"+attribute_name.to_s+"_#{input_html_options[:panel_class]}"
    <<-JAVASCRIPT
		<div class="spinner #{discern_class}">
	      #{@builder.text_field(attribute_name, input_html_options)}
	      <div class="spinner-buttons  btn-group btn-group-vertical">
	        <a href='javascript:void(0)' class="btn spinner-up" style="height:9px;">
	          <i class="icon-chevron-up pinner-icon"></i>
	        </a>
	        <a href='javascript:void(0)' class="btn spinner-down" style="height:9px;">
	          <i class="icon-chevron-down pinner-icon"></i>
	        </a>
	      </div>
	    </div>
    <SCRIPT type='text/javascript'>
     	new SpinnerView({el: '.#{discern_class}'})
    </SCRIPT>
    JAVASCRIPT
    .html_safe
  end
end
