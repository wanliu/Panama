class Admins::Shops::TransactionsController < Admins::Shops::SectionController

  def pending
    transactions = OrderTransaction.where(:seller_id => current_shop.id)
    @untransactions = transactions.where(:operator_state => false)
    @transactions = transactions.where(:operator_state => true).joins(:operator)
    .where("transaction_operators.operator_id=?", current_user.id)
  end

  def show
    @transaction = OrderTransaction.find_by(
      :seller_id => current_shop.id, :id => params[:id])
    respond_to do | format |
      format.html
    end
  end

  def render(*args)
    options = args.extract_options!
    if request.xhr?
      options[:layout] = false
    end

    super *args, options
  end

  def event
    @transaction = OrderTransaction.find(params[:id])
    # authorize! :event, @transaction
    if @transaction.fire_events!(params[:event])
      render partial: 'transaction',
                   object:  @transaction,
                   locals: {
                     state:  @transaction.state,
                     people: @people
                   }
      # render :partial => 'transaction', :transaction => @transaction, :layout => false
      # redirect_to person_transaction_path(@people.login, @transaction)
    end
  end

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
    respond_to do |format|
      format.json{ render :json => @transaction.messages  }
    end
  end
end
