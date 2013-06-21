#encoding: utf-8

ActiveAdmin.register Activity do
  index do
    column :id
    column "预览" do |row|
      row.attachments.each do |atta|
        image_tag atta.file.url("100x100")
      end
    end
    column :description
    column :author

    default_actions
  end
end