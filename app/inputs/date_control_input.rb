class DateControlInput < SimpleForm::Inputs::Base

  def input
  	discern_class = object.class.to_s
    <<-JAVASCRIPT
    <div id="datetimepicker1" class="input-append date">
      <input data-format="yyyy/MM/dd hh:mm:ss" type="text"></input>
      <span class="add-on">
        <i data-time-icon="icon-time" data-date-icon="icon-calendar">
        </i>
      </span>
    </div>
    <script type="text/javascript">
      $(function() {
        $('#datetimepicker1').datetimepicker({
           pickTime: false
        });
      });
    </script>
    JAVASCRIPT
    .html_safe
  end
end