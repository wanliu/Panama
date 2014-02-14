class ComboBoxWidget < CommonWidget
  helper_method :options_for_items
  
  protected 
  def options_for_items(items, selected)
    output = ActiveSupport::SafeBuffer.new
    items.each do |item|
      if selected == item[:value]
        sel_string = "selected=\"selected\"".html_safe
      end
      output << "<option value=#{item[:value]} #{sel_string}>#{item[:text]}</option>".html_safe
    end
    output
  end  
end