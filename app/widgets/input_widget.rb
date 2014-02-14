class InputWidget < CommonWidget
  def display(default, html_options)
    @default = default
    @html_options = html_options
    render
  end

end
