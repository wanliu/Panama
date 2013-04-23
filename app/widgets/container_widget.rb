class ContainerWidget < CommonWidget
  responds_to_event :change

  def display(content = nil)
    content_type, @content = if content.nil?
                              [:article, ""]
                            else
                              [content.class.name.underscore.to_sym, content.data]
                            end

    render_content(content_type, @content)
#    trigger(:change, {:value => 'article'})
#    render
  end

  def change(evt)
    content_type = evt[:value]
    widget("contents/#{content_type}", content_type.to_sym).build(root) unless root.find_widget(content_type)
    replace ".child", :widget => content_type, :view => :display
  end

  def render_content(content_type, content)
    widget("contents/#{content_type}", content_type.to_sym).build(root) unless root.find_widget(content_type)
    render({:widget => content_type, :state => :display}, content)
  end

end
