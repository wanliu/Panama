module Admins::Shops::ProductsHelper

    def picture_and_name(record)        
      content_tag :div, :class => 'btn-group' do        
        
        imgs = record.attachments.map do | a |
            image_tag(a.attachable.url("30x30"))
        end   

        imgs.join.html_safe + label_tag(record.name)
      end
    end
end
