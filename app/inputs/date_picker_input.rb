class DatePickerInput < SimpleForm::Inputs::Base

  def input
    element_id = input_options[:id] || rand.to_s.split(".").last
    format = input_options[:value] 

    <<-JAVASCRIPT
    <div id="#{element_id}" class="input-append date">
      <input data-date-format="#{format}" type="text"></input>
      <span class="add-on">
        <i data-time-icon="icon-time" data-date-icon="icon-calendar">
        </i>
      </span>
    </div> 
    <script type="text/javascript">
      require(['jquery', 'lib/bootstrap-datetimepicker.min'], function($){
        $(function() {
          $("##{element_id}").datetimepicker({
            format: "#{format}"
             //pickTime: false
          });
        });
      });
    </script>
    JAVASCRIPT
    .html_safe
  end
end