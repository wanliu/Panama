class ColoursInput < SimpleForm::Inputs::CollectionSelectInput
	def input
		# debugger
		collection.each do |item|
			"<span style='width:50px; height:50px; background-color: #{item['rgb']}'>&nbsp;</span>#{@builder.check_box(attribute_name, input_html_options)}".html_safe
		end
	end
end