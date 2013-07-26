#encoding: utf-8
class Admins::Shops::TransactionsController < Admins::Shops::SectionController

  def pending
    transactions = OrderTransaction.seller(current_shop).uncomplete.order("created_at desc")
    @untransactions = transactions.where(:operator_state => false)
    @transactions = transactions.where(:operator_state => true).joins(:operator)
    .where("transaction_operators.operator_id=?", current_user.id)
  end

  def complete
    @transactions = OrderTransaction.seller(current_shop).completed.order("created_at desc")
  end

  def page
    @transaction = OrderTransaction.find_by(
      :seller_id => current_shop.id, :id => params[:id])
    respond_to do | format |
      format.html
    end
  end

  def print
    @transaction = OrderTransaction.find_by(
      :seller_id => current_shop.id, :id => params[:id])
    render :layout => "print"
  end

  def show
    @transaction = OrderTransaction.find_by(
      :seller_id => current_shop.id, :id => params[:id])
    respond_to do | format |
      format.html
      format.csv do
        send_data(to_csv(OrderTransaction.export_column, @transaction.convert_json),
          :filename => "order#{DateTime.now.strftime('%Y%m%d%H%M%S')}.csv")
      end
    end
  end

  def event
    @transaction = OrderTransaction.find_by(
      :id => params[:id], :seller_id => current_shop.id)
    if @transaction.seller_fire_event!(params[:event])
      @transaction.notice_change_buyer(params[:event])
      render partial: 'transaction',
                   object:  @transaction,
                   locals: {
                     state:  @transaction.state,
                     people: @people
                   }
    else
      redirect_to shop_admins_pending_path(current_shop.name)
    end
  end

  def update_delivery
    @transaction = OrderTransaction.find(params[:id])
    respond_to do |format|
      if @transaction.state_name == :waiting_delivery
        @transaction.delivery_code = params[:delivery_code]
        @transaction.logistics_company_id = params[:logistics_company_id]
        if @transaction.save
          format.json{ head :no_content }
        else
          format.json{ render :json => draw_errors_message(@transaction), :status => 403 }
        end
      else
        format.json{ render :json =>{message: 'invalid state'}, :status => 403 }
      end
    end
  end

  #处理订单
  def dispose
    @transaction = OrderTransaction.find_by(:seller_id => current_shop.id, :id => params[:id])
    if @transaction.operator_create(current_user.id)
      @transaction.unmessages.update_all(
        :read => true,
        :receive_user_id => current_user.id)
      ChatMessage.notice_read_state(current_user, @transaction.buyer.id)
      render partial: 'transaction',object:  @transaction,
       locals: {
         state:  @transaction.state,
         people: current_user
       }
    else
      render :json => draw_errors_message(@transaction), :status => 403
    end
  end

  def dialogue
    @transaction = OrderTransaction.find_by(:seller_id => current_shop.id, :id => params[:id])
    @transaction_message_url = shop_admins_transaction_path(current_shop.name, @transaction.id)
    render :partial => "transactions/dialogue", :layout => "transaction_message", :locals => {
      :transaction_message_url => @transaction_message_url,
      :transaction => @transaction }
  end

  def send_message
    @transaction = OrderTransaction.find_by(:seller_id => current_shop.id, :id => params[:id])
    @message = @transaction.chat_messages.create(
      params[:message].merge(send_user: current_user, receive_user: @transaction.buyer))

    respond_to do |format|
      format.json{ render :json => @message }
    end
  end

  def messages
    @transaction = OrderTransaction.find_by(:seller_id => current_shop.id, :id => params[:id])
    @messages = @transaction.messages.order("created_at desc").limit(30)
    respond_to do |format|
      format.json{ render :json =>  @messages}
    end
  end

  private
  def render(*args)
    options = args.extract_options!
    if request.xhr?
      options[:layout] = false
    end

    super *args, options
  end
end
