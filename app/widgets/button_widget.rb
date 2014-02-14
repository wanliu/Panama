class ButtonWidget < CommonWidget
  responds_to_event :click

  def display(title, url_options = "#", html_options = {})
    @title = title
    @url_options = url_options

    default_options = {
      :id => widget_id,
      :class => [:btn],
      'data-event-url' => url_for_event(:click)
    }

    default_options[:class] << html_options.delete(:class) unless html_options[:class].nil?
    @html_options = html_options.reverse_merge! default_options

    render
  end

  def click
    nil
  end
end
