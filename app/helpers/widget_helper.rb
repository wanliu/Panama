module WidgetHelper
  STATE_BUTTON_SCRIPT = <<-JAVASCRIPT
    $(".state_button").on('click', function(){
      var state = $(this).attr('state') === 'true';
      STATUS = {true: 'on', false: 'off'};
      $(this).find("." + STATUS[state] + "_state").hide();
      state = !state;
      $(this).find("." + STATUS[state] + "_state").show();
    });
  JAVASCRIPT

  def trigget(target, event, options = {})
    widget = controller.root.find_widget(target)
    widget.url_for_event(event, options)
  end

  def state_button(on_or_off, on, off, options)
    options[:state] = on_or_off
    styles = ['display:none', nil]

    options = apppend_class(options, "state_button")

    link_to('#',options) do
      content_tag :ul, :class => 'unstyled' do
        on_styles, off_styles = on_or_off ? styles : styles.reverse

        on_tag  = content_tag :li, on, :style => on_styles, :class => :on_state
        off_tag = content_tag :li, off, :style => off_styles, :class => :off_state
        on_tag + off_tag
      end
    end +
    register_javascript(:state_button) do
      javascript_tag STATE_BUTTON_SCRIPT.html_safe
    end
  end

  def collapse_button(state, *args)
    options = args.extract_options!
    options = apppend_class(options, "collapse_button")
    state_button(state, caret(:down), caret(:right), options)
  end

  def apppend_class(options, name)
    options[:class] ||= []
    case options[:class]
    when Array
      options[:class].push(name)
    else
      options[:class] = [options[:class], name]
    end
    options
  end
end
