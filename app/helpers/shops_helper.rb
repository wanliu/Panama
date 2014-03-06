# encoding: utf-8
module ShopsHelper

  def circle_button(circle)
    link_to "#" do
      # image_tag(circle.photos.icon, :class => 'avatar avatar-icon') + ' ' + circle.name
      image_tag(circle.photos.icon, :class => 'avatar avatar-icon', 'data-toggle' => "tooltip", 'title' => "商圈名： #{circle.name}")
    end
  end
end
