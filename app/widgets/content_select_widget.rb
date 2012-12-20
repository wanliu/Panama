class ContentSelectWidget < ComboBoxWidget

  def display(query)
    @query = query
    @items = [
      {value: 'article', text: 'Article'}, 
      {value: 'text', text: 'Text'},
      {value: 'datetime', text: 'Date && Time'},
      {value: 'query_language', text: 'Data Query'},
      {value: 'page', text: 'Page'}
    ]
    
    render
  end
end
