#encoding: utf-8
class People::TransactionsController < People::BaseController
  # GET /people/transactions
  # GET /people/transactions.json
  def index
    authorize! :index, OrderTransaction
    @transactions = OrderTransaction.where(:buyer_id => @people.id).order("created_at desc").page(params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @transactions }
    end
  end

  # GET /people/transactions/1
  # GET /people/transactions/1.json
  def show
    @transactions = OrderTransaction.where(:buyer_id => @people.id).page params[:page]
    @transaction = OrderTransaction.find(params[:id])
    authorize! :show, @transaction
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @transaction }
    end
  end

  def page
    @transactions = OrderTransaction.where(:buyer_id => @people.id).page params[:page]
    @transaction = OrderTransaction.find(params[:id])
    authorize! :show, @transaction
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def event
    @transaction = OrderTransaction.find(params[:id])
    event_name = params[:event]
    authorize! :event, @transaction
    if @transaction.buyer_fire_event!(event_name)
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

  def batch_create
    # flag = false
    # my_cart.items.group_by { |item| item.product.shop }.each do |shop, items|
    #   transaction = @people.transactions.build seller_id: shop.id
    #   items.each {|item| transaction.items.build item.attributes }
    #   transaction.items_count = items.inject(0) { |s, item| s + item.amount }
    #   transaction.total = items.inject(0) { |s, item| s + item.total }
    #   flag = transaction.save
    # end
    # cart.destroy if flag
    # FIXME @people这个参数是不是多余？ cart的user不就是@people么？
    authorize! :batch_create, OrderTransaction
    if my_cart.create_transaction(@people)
      redirect_to person_transactions_path(@people.login),
                  notice: 'Transaction was successfully created.'
    else
      # FIXME
      redirect_to person_cart_index_path(@people.login),
                  notice: 'We are sorry, but the transaction was not successfully created.'
    end
  end

  # POST /people/transactions
  # POST /people/transactions.json
  def create
    @transaction = @people.transactions.build(params[:order_transaction])

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to person_transaction_path(@people.login, @transaction), notice: 'OrderTransaction was successfully created.' }
        format.json { render json: @transaction, status: :created, location: @transaction }
      else
        format.html { render action: "new" }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  def address
    @transaction = OrderTransaction.find(params[:id])
    t, a = params[:order_transaction], params[:address]
    respond_to do |format|
      options = if t[:address_id].present?
        {:address_id => t[:address_id]}
      else
        address = Address.new({
          :province_id => a[:province_id],
          :city_id => a[:city_id],
          :area_id => a[:area_id],
          :zip_code => a[:zip_code],
          :road => a[:road]
        })
        address.user_id = current_user.id
        address.save
        {:address_id => address.id}
      end
      options[:delivery_price] = t[:delivery_price] || 0
      options[:delivery_type_id] = t[:delivery_type_id]
      if @transaction.update_attributes(options)
        format.json{ head :no_content }
      else
        format.json{ render :json => draw_errors_message(@transaction), :status => 403 }
      end
    end
  end

  def get_delivery_price
    @price = OrderTransaction.find(params[:id]).get_delivery_price(params[:delivery_type_id])
    respond_to do |format|
      format.json{ render :json => {delivery_price: @price} }
    end
  end

  def refund
    order = OrderTransaction.find(params[:id])
    items = params[:order_refund].delete(:product_items)
    respond_to do |format|
      refund = order.refunds.create(params[:order_refund])
      if refund.valid?
        refund.create_items(items)
        if refund.items.count <= 0
          refund.destroy
          format.json{ render :json => {message: "申请退货失败"}, :status => 403 }
        else
          format.json{ render :json => refund }
        end
      else
        format.json{ render :json => draw_errors_message(refund), :status => 403 }
      end
    end
  end

  def notify
  end

  def done
  end

  # DELETE /people/transactions/1
  # DELETE /people/transactions/1.json
  def destroy
    @transaction = OrderTransaction.find(params[:id])
    authorize! :destroy, @transaction
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to person_transactions_path(@people.login) }
      format.json { head :no_content }
    end
  end

  def render(*args)
    options = args.extract_options!
    if request.xhr?
      options[:layout] = false
    end

    super *args, options
  end

  def dialogue
    @transaction = current_user.transactions.find(params[:id])
    @transaction_message_url = person_transaction_path(current_user, @transaction)
    render :partial => "transactions/dialogue", :layout => "transaction_message", :locals => {
      :transaction_message_url => @transaction_message_url,
      :transaction => @transaction }
  end

  def send_message
    @transaction = current_user.transactions.find(params[:id])
    @message = @transaction.message_create(params[:message].merge(send_user: current_user))

    respond_to do |format|
      format.json{ render :json => @message }
    end
  end

  def messages
    @transaction = current_user.transactions.find(params[:id])
    @messages = @transaction.messages.order("created_at desc").limit(30)
    respond_to do |format|
      format.json{ render :json => @messages  }
    end
  end
end
