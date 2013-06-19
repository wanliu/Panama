#encoding: utf-8

ActiveAdmin.register Activity do
  index do
    column :id
    column "预览" do |row|
      image_tag row.url, :style => "width:100px"
    end
    column :description
    column :author
    # column :user
    default_actions
  end
end