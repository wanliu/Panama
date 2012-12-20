class ComboBoxWidget < CommonWidget
  helper_method :options_for_items
  
  protected 
  def options_for_items(items)
    output = ActiveSupport::SafeBuffer.new
    items.each do |item|
      output << "<option value=#{item[:value]}>#{item[:text]}</option>".html_safe
    end
    output
  end  
end