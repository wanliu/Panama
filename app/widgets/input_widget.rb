class InputWidget < CommonWidget
  def display(name, default, html_options)
    @name = name
    @default = default
    @html_options = html_options
    render
  end

end
