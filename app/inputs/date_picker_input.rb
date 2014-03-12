class DatePickerInput < SimpleForm::Inputs::Base

  def input
    # element_id = input_options[:id] || rand.to_s.split(".").last
    format = input_options[:input_html][:format] || 'yyyy-mm-dd'
    value = input_options[:input_html][:value]

    <<-JAVASCRIPT
    <div id="#{element_id}" class="input-append date form_datetime">
      <input type="text"  #{input_html}></input>
      <span class="add-on">
        <i class="icon-th"></i>
      </span>
    </div>
    <script type="text/javascript">
      $(function() {
        var $elem = $("##{element_id}")
        $elem.datetimepicker({
          'pickTime': false,
          'language': 'zh-CN',
          'weekStart': 1,
          'autoclose': true,
          'minView': 2,
          'viewSelect': 'month',
          'formatViewType': 'month',
          'format': "#{format}"
        })
        
        $("input:text", $elem).blur(function(){
          $elem.data("datetimepicker").setValue(this.value.trim())
        })        

      });
    </script>
    JAVASCRIPT
    .html_safe
  end

  def element_id
    input_options[:id] || "#{object_name}_#{attribute_name}"

    # .on('changeDate', function(event){
    #       $('.bootstrap-datetimepicker-widget').hide();
    #     });
  end

  def input_html
    properties = ""

    input_options[:input_html].each do |key, value|
      properties << "#{ key }='#{ value }' "
    end if input_options[:input_html]

    properties
  end
end