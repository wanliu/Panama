class ColoursInput < SimpleForm::Inputs::CollectionSelectInput
	def input
		debugger
		"$ #{@builder.check_box(attribute_name, input_html_options)}".html_safe
	end
end