class ContainerWidget < CommonWidget
  responds_to_event :change  

  def display
    render
#    trigger(:change, {:value => 'article'})    
#    render
  end

  def change(evt)
    content_type = evt[:value]
    widget("contents/#{content_type}", content_type.to_sym).build(root) unless root.find_widget(content_type)
    replace ".child", :widget => content_type, :view => :display
  end

end
