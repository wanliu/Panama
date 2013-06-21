module CategoryHelper

  def tree_cls_name(c, last)
    cls_name = "expandable" if c.children.length > 0
    last_name = "last#{cls_name.to_s.camelcase}" if c == last

    unless cls_name.nil?
      hitarea_name = "#{last_name}-hitarea" unless last_name.nil?
      hitarea_name = "#{cls_name}-hitarea #{hitarea_name}"
    end

    ["#{cls_name} #{last_name}", hitarea_name]
  end
end
