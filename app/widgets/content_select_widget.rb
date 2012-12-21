class ContentSelectWidget < ComboBoxWidget

  def display(selected)
    unless selected.nil?
      @selected = selected.class.undescore
    end
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
