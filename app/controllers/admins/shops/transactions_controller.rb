#encoding: utf-8
class Admins::Shops::TransactionsController < Admins::Shops::SectionController
  helper_method :base_template_path

  def pending
    @untransactions = current_shop_order.where(:operator_state => false)
    @transactions = current_shop_order.uncomplete.joins(:operator)
    .where("operator_state=true and transaction_operators.operator_id=?", current_user.id)
    .order("dispose_date desc").page(params[:page])
  end

  def generate_token
    @transaction = current_shop_order.find(params[:id])
    @transaction.send('create_the_temporary_channel')
    
    respond_to do |format|
      format.json{ render :json => { token: @transaction.temporary_channel.try(:token) } }
    end
  end

  def complete
    @transactions = current_shop_order.completed.order("created_at desc").page(params[:page])
    @direct_transactions = current_shop.direct_transactions.completed.order("created_at desc").page(params[:page])
  end

  def page
    @transaction = current_shop_order.find_by(:id => params[:id])
    respond_to do | format |
      format.html
    end
  end

  def print
    @transaction = current_shop_order.find_by(:id => params[:id])
    render :layout => "print"
  end

  def show
    @transaction = current_shop_order.find_by(:id => params[:id])
    respond_to do | format |
      format.html
      format.json{ render :json => @transaction.as_json(:methods => :seller_state_title) }
      format.csv do
        send_data(to_csv(OrderTransaction.export_column, @transaction.convert_json),
          :filename => "order#{DateTime.now.strftime('%Y%m%d%H%M%S')}.csv")
      end
    end
  end

  def event
    @transaction = current_shop_order.find_by(:id => params[:id])
    if @transaction.seller_fire_event!(params[:event])
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
    @transaction = current_shop_order.find(params[:id])
    respond_to do |format|
      @transaction.delivery_code = params[:delivery_code]
      if @transaction.save
        format.json{ head :no_content }
      else
        format.json{ render :json => draw_errors_message(@transaction), :status => 403 }
      end
    end
  end

  def update_delivery_price
    @transaction = current_shop_order.find(params[:id])
    respond_to do |format|
      @transaction.delivery_price = params[:delivery_price] || 0
      if @transaction.save
        format.json{ head :no_content }
      else
        format.json{ render draw_errors_message(@transaction), :status => 403  }
      end
    end
  end

  #处理订单
  def dispose
    @transaction = current_shop_order.find_by(:id => params[:id])
    respond_to do |format|
      @operator = @transaction.operator_create(current_user.id)
      if @operator.valid?
        @transaction.unmessages.update_all(
          :read => true,
          :receive_user_id => current_user.id)
        ChatMessage.notice_read_state(current_user, @transaction.buyer.id)
        format.html{
          render partial: 'transaction',object:  @transaction,
           locals: {
             state:  @transaction.state,
             people: current_user
           }
        }
      else
        format.json{
          render :json => draw_errors_message(@operator), :status => 403 }
      end
    end
  end

  def dialogue
    @transaction = current_shop_order.find_by(:id => params[:id])
    @transaction_message_url = shop_admins_transaction_path(current_shop.name, @transaction.id)
    render :partial => "transactions/dialogue", :layout => "message", :locals => {
      :transaction_message_url => @transaction_message_url,
      :transaction => @transaction }
  end

  def send_message
    @transaction = current_shop_order.find_by(:id => params[:id])
    @message = @transaction.chat_messages.create(
      params[:message].merge(
        send_user: current_user,
        receive_user: @transaction.buyer))

    respond_to do |format|
      format.json{ render :json => @message }
    end
  end

  def messages
    @transaction = current_shop_order.find(params[:id])
    @messages = @transaction.messages.order("created_at desc").limit(30)
    respond_to do |format|
      format.json{ render :json => @messages}
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

  def current_shop_order
    OrderTransaction.seller(current_shop)
  end

  def base_template_path
    "admins/shops/transactions/base"
  end
end
