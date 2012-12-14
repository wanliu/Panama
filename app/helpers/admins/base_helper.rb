module Admins
  module BaseHelper

    def side_bar(name)
      render :partial => "sidebar", :locals => { :name => name , :sections => controller.sections }
    end
  end
end