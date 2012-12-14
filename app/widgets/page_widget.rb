class PageWidget < CommonWidget
  # state :new, ""
  define_option :state, :state

  attr_reader :status
  
  def display(_state)
    _state = status.find { |s| s[:name] == _state } 
    if _state.nil?
      raise "can't found #{_state} state in Widget #{self}"
    else
      render :file => _state[:path]
    end
  end

  def state(name, path)
     status << { name: name, path: path }
  end

  protected
  def status
    @status ||= []
  end
end
