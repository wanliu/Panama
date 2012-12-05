module Admins
  module BaseHelper

    def side_bar(name)
      content_tag :div, :id => name do 
        output = ActiveSupport::SafeBuffer.new
        controller.sections.each do |section|
          output.safe_concat(capture do
            render :partial => "section",  :locals => section
          end)
        end
        output
      end
    end
  end
end