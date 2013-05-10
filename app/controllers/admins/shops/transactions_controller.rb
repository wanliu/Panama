class Admins::Shops::TransactionsController < Admins::Shops::SectionController

  def pending
    @untransactions = OrderTransaction.where(:seller_id => current_shop.id, :operator_state => false)
    @transactions = OrderTransaction.where(:seller_id => current_shop.id, :operator_state => true)
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
    if @transaction.operators.create(:operator_id => current_user.id)
      @transaction.change_operator_state
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
