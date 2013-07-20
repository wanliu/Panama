ActiveAdmin.register UserChecking do
  scope :waiting_audit, default: true do
    UserChecking.where("shop_name <> ''")
  end

  index do
    column :user
    column :shop_name
    column :ower_name
    column :ower_shenfenzheng_number
    default_actions
  end

  # member_action :check do
  #   @user_checking = UserChecking.find(params[:id])
  # end

end