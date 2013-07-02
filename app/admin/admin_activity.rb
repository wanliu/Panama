#encoding: utf-8

ActiveAdmin.register Activity do
  index do
    column :id
    column "预览图" do |row|
      if row.attachments.length > 0
        image_tag row.attachments.first.file.url("100x100")
      end
    end
    column :description
    column :author

    default_actions
  end
end