class Contents::ArticleWidget < Apotomo::Widget
  responds_to_event :save

  has_widgets do 
    self << widget(:button, :save_article)
    self << widget(:button, :cancel_article)      
  end

  def display(content)
    @content = content
    render
  end

  def save(evt)
    if evt[:content_id].nil?
      @content = Contents::Article.create(data: evt[:content])
    else
      @content = Contents::Article.find(evt[:content_id])
    end
    render :text => "alert('save is ok!')"
  end
end
