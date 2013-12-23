#encoding: utf-8

class Admins::Shops::DirectTransactionsController < Admins::Shops::SectionController

  def index
    @direct_transactions = current_shop.direct_transactions.uncomplete.order("created_at desc").page(params[:page])
  end

  def dialog
    @direct_transaction = current_shop_direct_transaction
    render :partial => "direct_transactions/dialog",
    :layout => "message", :locals => {
      :direct_transaction => @direct_transaction,
      :dtm_url => shop_admins_direct_transaction_path(current_shop, @direct_transaction)
    }
  end

  def page
    @direct_transaction = current_shop_direct_transaction
    render :partial => "show", :locals => { direct_transaction: @direct_transaction }
  end

  def messages
    @direct_transaction = current_shop_direct_transaction
    @messages = @direct_transaction.messages.order("created_at desc").limit(30)
    respond_to do |format|
      format.json{ render :json => @messages }
    end
  end

  def send_message
    @direct_transaction = current_shop_direct_transaction
    @message = @direct_transaction.messages.create(
      params[:message].merge(
        :receive_user => @direct_transaction.buyer,
        :send_user => current_user))
    respond_to do |format|
      format.json{ render :json => @message }
    end
  end

  def dispose
    @direct_transaction = current_shop_direct_transaction
    @direct_transaction.operator = current_user
    if @direct_transaction.save
      @direct_transaction.unmessages.update_all(:receive_user_id => current_user.id)
      render :partial => "admins/shops/direct_transactions/show", :locals => {
        :direct_transaction => @direct_transaction
      }
    else
      render :json => draw_errors_message(@direct_transaction), :status => 403
    end
  end

  def show
    @direct_transaction = current_shop_direct_transaction
    respond_to do |format|
      format.html
    end
  end

  def item
    @direct_transaction = current_shop_direct_transaction
    render :layout => false
  end

  private
  def current_shop_direct_transaction
    current_shop.direct_transactions.find(params[:id])
  end
end