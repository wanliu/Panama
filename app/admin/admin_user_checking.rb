#encoding: utf-8

ActiveAdmin.register UserChecking do
  scope :等待审核, default: true do
    UserChecking.where("shop_name <> '' and rejected = ? and checked = ?", false, false)
  end

  scope :被驳回 do
    UserChecking.where("rejected = ? and checked <> ?", true, true)
  end

  scope :已审核通过 do
    UserChecking.where("checked = ?", true)
  end

  actions :index, :show

  index do
    column :user
    column :service
    column :shop_name
    column :ower_name
    column :ower_shenfenzheng_number
    default_actions
  end

  show do
    render "check_info"
  end

  member_action :check, method: :post do
    user_checking = UserChecking.find(params[:id])

    if user_checking.update_attributes(checked: true)
      if user_checking.user.try(:shop)
        shop = user_checking.user.shop
        shop.actived = true
        shop.photo = user_checking.shop_photo  if user_checking.shop_photo
        shop.save!
      end
    end

    user_checking.send_checked_mail

    redirect_to action: :index
  end

  member_action :reject, method: :post do
    user_checking = UserChecking.find(params[:id])
    user_checking.update_attributes(rejected: true, rejected_reason: params[:reject_reason])
    user_checking.update_rejected_times
    user_checking.send_rejected_mail

    redirect_to action: :index
  end
end