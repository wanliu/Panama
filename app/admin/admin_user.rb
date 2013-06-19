#encoding: utf-8
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
    f.inputs "管理员详细信息" do
      f.input :login
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
