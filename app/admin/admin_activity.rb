ActiveAdmin.register Activity do
  index do
    column :id
    column "preview" do |row|
      image_tag row.url, :style => "width:100px"
    end
    column :description
    column :author
    # column :user
    default_actions
  end
end