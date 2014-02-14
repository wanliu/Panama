class TemplateComboBoxWidget < ComboBoxWidget
  responds_to_event :change

  def display
    @shop = options[:shop]
    @files = @shop.fs['templates/*'].map do |file| 
      {value: file.path, text: file.name.sub(/\..*/,'').capitalize } 
    end

    render
  end

  def change
    render
  end


end
