module WidgetHelper

  def trigget(target, event, options = {})
    widget = controller.root.find_widget(target)
    widget.url_for_event(event, options)
  end
end
