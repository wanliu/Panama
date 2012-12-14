class ContentSelectWidget < CommonWidget
  helper_method :options_for_items
  responds_to_event :choose

  def display(query)
    @query = query
    @items = [
      {value: 'article', text: 'Article'}, 
      {value: 'text', text: 'Text'},
      {value: 'datetime', text: 'Date && Time'},
      {value: 'query_language', text: 'Data Query'}
    ]
    
    render
  end

  def choose(event)
  end

  protected 
  def options_for_items(items)
    output = ActiveSupport::SafeBuffer.new
    items.each do |item|
      output << "<option value=#{item[:value]}>#{item[:text]}</option>".html_safe
    end
    output
  end

end
