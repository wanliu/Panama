class SpinnerInput < SimpleForm::Inputs::Base

  def input
  	input_html_options[:class].push("input-mini spinner-input")
  	input_html_options[:maxlength] = input_options[:maxlength] || "3"
  	input_html_options[:value] = input_options[:value] || "1"

  	discern_class = "spinner_"+object.class.to_s+"_"+attribute_name.to_s
    <<-JAVASCRIPT 
		<div id="MySpinner" class="spinner #{discern_class}"> 
	      #{@builder.text_field(attribute_name, input_html_options)}
	      <div class="spinner-buttons  btn-group btn-group-vertical">
	        <button class="btn spinner-up">
	          <i class="icon-chevron-up"></i>
	        </button>
	        <button class="btn spinner-down">
	          <i class="icon-chevron-down"></i>
	        </button>
	      </div>
	    </div> 
    <SCRIPT type='text/javascript'>
    	require(['jquery', 'lib/spinner'], function($,Spinner){
        	new Spinner.SpinnerView({el: '.#{discern_class}'})
        });
    </SCRIPT>
    JAVASCRIPT
    .html_safe
  end
end
