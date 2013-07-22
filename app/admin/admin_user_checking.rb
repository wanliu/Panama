ActiveAdmin.register UserChecking do
  scope :waiting_audit, default: true do
    UserChecking.where("shop_name <> ''")
  end

  actions :index, :show

  index do
    column :user
    column :shop_name
    column :ower_name
    column :ower_shenfenzheng_number
    default_actions
  end

  # action_item only: :show do |resource|
  #   link_to('New Post', new_resource_path(resource))
  # end

  show do
    render "check_info"
  end

  member_action :check, method: :post do
    user_checking = UserChecking.find(params[:id])
    user = user_checking.user
    user.services << Service.where(service_type: "seller")
    # user.save
    redirect_to action: :show
  end

  member_action :reject, method: :post do
    debugger
  end

end