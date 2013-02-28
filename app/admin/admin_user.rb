ActiveAdmin.register AdminUser do
  index do
    column :login
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    default_actions
  end

  filter :login

  form do |f|
    f.inputs "Admin Details" do
      f.input :login
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end

ActiveAdmin.register Category do
  index do
    column :id
    column :name
    column :ancestry
    column :created_at
    column 'tool' do
      link_to "View Site", "/", :class => 'btn'
    end

  end

  member_action :comments do
    category = Category.find(params[:id])
  end
end

ActiveAdmin.register Product do
  index do
    column :id
    column :name
  end
end

ActiveAdmin.register Shop do
  index do
    column :id
    column :name
    column :user
  end
end

ActiveAdmin.register Activity do
  index do
    column :id
    column :name
    # column :user
  end
end