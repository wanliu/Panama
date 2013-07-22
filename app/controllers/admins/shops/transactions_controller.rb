class Admins::Shops::TransactionsController < Admins::Shops::SectionController

  def pending
    transactions = OrderTransaction.where("seller_id=? and state not in (?)",
      current_shop.id, [:complete, :close]).order("created_at desc")
    @untransactions = transactions.where(:operator_state => false)
    @transactions = transactions.where(:operator_state => true).joins(:operator)
    .where("transaction_operators.operator_id=?", current_user.id)
  end

  def complete
    transactions = OrderTransaction.where(:seller_id => current_shop.id).order("created_at desc")
    @transactions = transactions.where(:state => "complete")
  end

  def page
    @transaction = OrderTransaction.find_by(
      :seller_id => current_shop.id, :id => params[:id])
    respond_to do | format |
      format.html
    end
  end

  def show
    @transaction = OrderTransaction.find_by(
      :seller_id => current_shop.id, :id => params[:id])
    respond_to do | format |
      format.html
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

  def delivery_code
    @transaction = OrderTransaction.find(params[:id])
    respond_to do |format|
      if @transaction.state_name == :waiting_delivery
        @transaction.delivery_code = params[:delivery_code]
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
