module Admins::Shops::ProductsHelper

    def picture_and_name(record)
      content_tag :div, :class => 'btn-group' do
        image_tag(record.preview.url("30x30")) +
        label_tag(record.name)
      end
    end
end
