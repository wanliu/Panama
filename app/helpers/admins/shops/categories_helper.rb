module Admins::Shops::CategoriesHelper

  def indent_attributes(indent)
    default_indent_attributes(indent).map {|k,v| "#{k}=#{v}" }.join(' ')
  end

  def default_indent_attributes(indent)
    {
      :indent => indent,
      :class => "indent_#{indent}"
    }.map
  end

  def tr_category_attributes(category)
    {
      id: category.id,
      indent: category.indent,
      :class => "indent_#{category.indent}"
    }.map {|k,v| "#{k}=#{v}" }.join(' ')
  end

  def category_util_field(category)
    if category.new_record?
      content_tag :div, :class => 'btn-group' do
        link_to(icon(:ok), "#/#{category.id}/", :class => 'btn utils save') +
        link_to(icon(:remove), "#",
          :'data-delete-url' => "#{category.id}",
          :class             => 'btn utils cancel')
      end
    else
      content_tag :div, :class => 'btn-group' do
#        link_to(icon(:edit), "#/#{category.id}/edit", :class => 'btn utils edit') +
        link_to(icon(:ok), "#/#{category.id}/", :class => 'btn utils update') +
        link_to(icon(:remove), "#",
          :'data-delete-url' => admins_categories(category),
          :class             => 'btn utils delete')
      end
    end +
    register_javascript(:changed_highlight_save) do
      javascript_tag <<-JAVASCRIPT
        $("#table tr td :input").on('keydown', function(){
          var $this = $(this);
          var $buttons = $this.parents("tr").find("td a.utils");
          console.log($buttons);
          $buttons.each(function(i, button){
            var $btn = $(button);
            if ($btn.hasClass('save') || $btn.hasClass('edit')){
              if ($this.val().length == 0)
                $btn.removeClass('btn-primary');
              else
                $btn.addClass('btn-primary');
            }
          });
        })
      JAVASCRIPT
    end
  end

  def category_name_field(category)
    disabled = category.new_record? ? " disabled" : ""
    content_tag(:div, :class => 'btn-group') do
      collapse_button(true, :class => "category") +
      text_field_tag(:name, category.name)
    end +
    content_tag(:div, :class => 'btn-group') do
      link_to(caret, "#", :class =>"btn add_child#{disabled}")
    end +
    content_tag(:div, :class => 'btn-group') do
      link_to(icon(:picture), "#", :class =>'btn')
    end
  end

  def category_mini_field(category)
    content_tag(:div, :class => 'btn-group') do
      collapse_button(true, :class => "category") +
      label_tag(category.name, nil, :class => "category")
    end +
    content_tag(:div, :class => ["btn-group", "pull-right"]) do
      link_to(icon(:list), "#", :class => 'btn list_category_products btn-mini')
    end
  end
end
