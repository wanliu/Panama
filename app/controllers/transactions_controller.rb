class TransactionsController < ApplicationController
  def operate_url
    id = params[:id]
    type = params[:type]
    if id.blank? || type.blank?
      url = ''
    else
      if type == "OrderTransaction"
        type = 'order'
        order = OrderTransaction.find(id)
        if order.buyer == current_user
          # 担保交易买家订单地址
          url = person_transactions_path(current_user)
        else
          # 担保交易卖家订单地址
          url = shop_admins_pending_path(current_user.shop)
        end
      elsif type == "DirectTransaction"
        type = 'direct'
        order = DirectTransaction.find(id)
        if order.buyer == current_user
          # 直接交易买家订单地址
          url = person_direct_transactions_path(current_user)
        else
          # 直接交易卖家订单地址
          url = shop_admins_direct_transactions_path(current_user.shop)
        end
      end
      url += "#open/#{id}/#{type}"
    end
    
    render :json => { url: url }
  end
end