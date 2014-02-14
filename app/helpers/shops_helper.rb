# encoding: utf-8
module ShopsHelper

  def circle_button(circle)
    link_to community_circles_path(circle) do
      image_tag(circle.photos.icon, :class => 'avatar avatar-mini') + ' ' + circle.name
    end
  end
end
