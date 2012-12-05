class CommonCell < Cell::Rails
  helper ApplicationHelper

  MAX_DEEP_CHECK = 10

  def action_controller
    _controller = nil
    MAX_DEEP_CHECK.times.inject(parent_controller) do |parent, controller|
      if parent.is_a?(ActionController::Base)
        break _controller = parent
      end
      if parent.respond_to?(:parent_controller) 
        parent.parent_controller
      else
        nil
      end
    end
    _controller
  end  
end