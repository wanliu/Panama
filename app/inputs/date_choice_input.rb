class DateChoiceInput  < Formtastic::Inputs::StringInput

  def to_html 
  lable = options[:title]
  name = options[:name]
    <<-HTML
      <li class='string input optional stringish'>
        <label class="label" for="#{ name }">#{ lable }</label>
        <div style='position: relative;display: inline-block;'>
          <input class="ssh" type="text" name="#{ name }" />
          <a class="jquery-simpledatepicker-CalendarBut"></a>
        </div>
      </li> 
    HTML
    .html_safe
  end
end