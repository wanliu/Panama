ActiveAdmin.register Category do
  index do
    column :id
    column :name
    column :ancestry
    column :created_at
    default_actions
    # column 'tool' do
    #   link_to "View Site", "/", :class => 'btn'
    # end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :ancestry
    end
    f.buttons
  end

  member_action :comments do
    category = Category.find(params[:id])
  end
end