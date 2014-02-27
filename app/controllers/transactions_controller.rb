class TransactionsController < ApplicationController
  before_filter :login_and_service_required
  
  def operate_url
    url, type = self.send("#{params[:type].underscore}_by_url_type", params[:id])
    render :json => { url: "#{url}#open/#{params[:id]}/#{type}" }
  end

  private
  def direct_transaction_by_url_type(id)
    order = DirectTransaction.find(id)
    url = if order.buyer == current_user
      person_direct_transactions_path(current_user)
    else
      shop_admins_direct_transactions_path(current_user.shop)
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