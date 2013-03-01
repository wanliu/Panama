module PeopleHelper

  def active_section(name)
    content_for(:people_siderbar) do 
      name.to_s
    end
  end

  def render_the_styles
  	@product.styles.map do |style_group| # FIXME n+1
			"<label class='control-label'> #{ style_group.name } </label>
				<div class='controls'>
					<p class='style-group'> #{ style_items(style_group) } </p>
				</div>"
		end.join('').html_safe
  end

  def style_items(style_group) # FIXME n+1
  	valid_item(style_group).map do |item|
  		"<a class='style-items' href='javascript:void(0)' id='#{item.style_group.name}-style-#{item.id}'>
  			#{ item.title }
  		</a>"
  	end.join('')
  end

  def valid_item(style_group)
  	style_group.items.find_all { |item| item.checked }
  end

  # return array like ["{ colour_style_id: 3, size_style_id: 5, price: 22, quantity: 15 }", "{...}", "{...}"]
  def sub_products # FIXME n+1
  	@product.sub_products.map do |sub|
  		get_attributes(sub)
  	end.join(', ').html_safe
  end

  # return string like "{ colour_style_id: 3, size_style_id: 5, price: 22, quantity: 15 }"
  def get_attributes(sub) # FIXME n+1
  	html = ["id: #{ sub.id }, price: #{ sub.price }", "quantity: #{ sub.quantity }"]
  	sub.items.each do |attr|
  		html << "#{ attr.style_group.name }_style_id: '#{ attr.id }'"
  	end
    html = "{" << html.join(', ')
  	html << "}"
  end

end
