class TransactionsController < ApplicationController
  before_filter :login_and_service_required
  
  def operate_url
    url, type = self.send("#{params[:type].underscore}_by_url_type", params[:id])
    render :json => { url: "#{url}#open/#{params[:id]}/#{type}" }
  end

  def photos
    if params[:type] == 'DirectTransaction'
      order = DirectTransaction.find(params[:id])
    elsif params[:type] == 'OrderTransaction'
      order = OrderTransaction.find(params[:id])
    end
    unless order.blank?
      icon = if order.buyer == current_user
        # 当前用户为买家，显示对方(卖家)商店头像
        order.seller.try(:photos).try(:icon)
      else
        # 当前用户为卖家，显示对方(买家)个人头像
        order.buyer.try(:photos).try(:icon)
      end
    end
      
    render :json => { icon: icon }
  end

  private
  def direct_transaction_by_url_type(id)
    order = DirectTransaction.find(id)
    url = if order.buyer == current_user
      order.buyer.photos
    else
      order.seller.photos
    end
    [url, "direct"]
  end

  def order_transaction_by_url_type(id)
    order = OrderTransaction.find(id)
    url = if order.buyer == current_user
      # 担保交易买家订单地址
      person_transactions_path(current_user)
    else
      # 担保交易卖家订单地址
      shop_admins_pending_path(current_user.shop)
    end
    [url, "order"]
  end
end