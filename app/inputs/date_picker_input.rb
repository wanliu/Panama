class DatePickerInput < SimpleForm::Inputs::Base

  def input
    # element_id = input_options[:id] || rand.to_s.split(".").last
    format = input_options[:value] || ""
    <<-JAVASCRIPT
    <div id="#{element_id}" class="input-append date">
      <input data-date-format="#{format}" type="text" #{ input_html }></input>
      <span class="add-on">
        <i data-time-icon="icon-time" data-date-icon="icon-calendar">
        </i>
      </span>
    </div>
    <script type="text/javascript">
      $(function() {
        $("##{element_id}").datetimepicker({
           pickTime: false,
           language: "zh-CN",
           weekStart: 1,
           format: 'yyyy-mm-dd'
        });
      });
    </script>
    JAVASCRIPT
    .html_safe
  end

  def element_id
    input_options[:id] || "#{object_name}_#{attribute_name}"
  end

  def input_html
    properties = ""

    input_options[:input_html].each do |key, value|
      properties << "#{ key }='#{ value }' "
    end if input_options[:input_html]

    properties
  end
end