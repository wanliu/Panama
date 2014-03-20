#encoding: utf-8

class Admins::Shops::DirectTransactionsController < Admins::Shops::SectionController
  def index
    directs = current_shop.direct_transactions.order("created_at desc")
    @undirects = directs.where(:operator_id => nil)
    @directs = directs.uncomplete.where(:operator_id => current_user.id).page(params[:page])
  end

  def get_token
    @direct_transaction.temporary_channel.try(:token)
  end

  def generate_token
    @direct_transaction = current_shop_direct_transaction
    if get_token.blank?
      @direct_transaction.send('create_the_temporary_channel')
      try_times = 0
      while try_times < 50 do
        try_times += 1
        break unless get_token.blank?
        sleep 0.2
      end
    end
    
    respond_to do |format|
      format.json{ render :json => { token: get_token } }
    end
  end

  def completed
    @direct_transaction = current_direct_transaction
    @direct_transaction.state = :complete
    respond_to do |format|
      if @direct_transaction.save
        format.json{ render :json => @direct_transaction }
      else
        format.json{ render :json => draw_errors_message(@direct_transaction), :status => 403 }
      end
    end
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

  def dispose
    @direct_transaction = current_shop_direct_transaction
    respond_to do |format|
      if @direct_transaction.update_operator(current_user)
        format.html
        format.json{ render :json => @direct_transaction }
      else
        format.json{
          render :json => draw_errors_message(@operator), :status => 403
        }
      end
    end
  end

  def show
    @direct_transaction = current_shop_direct_transaction
    respond_to do |format|
      format.html
      format.json{ render :json => @direct_transaction }
      format.csv do
        send_data(to_csv(DirectTransaction.export_column, @direct_transaction.convert_json),
          :filename => "order#{DateTime.now.strftime('%Y%m%d%H%M%S')}.csv")
      end
    end
  end

  def print
    @direct_transaction = current_shop_direct_transaction
    render :layout => "print"
  end

  def mini_item
    @direct_transaction = current_shop_direct_transaction
    respond_to do |format|
      operator = @direct_transaction.operator
      if operator.present? && operator != current_user
        format.json{ render :json => ["这订单已经被#{operator.login}接了"], :status => 403 }
      elsif @direct_transaction.present?
        format.html{ 
          render :layout => false
        }    
      else
        format.json{ render :json => ["直接交易不存在！"], :status => 403 }  
      end
    end
  end

  def operator
    @operator = current_shop_direct_transaction.operator
    respond_to do |format|
      format.html{ 
        render :partial => "direct_transactions/operator", :locals => {operator: @operator} }
    end
  end

  private
  def current_shop_direct_transaction
    current_shop.direct_transactions.find_by(id: params[:id])
  end
end