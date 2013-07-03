#encoding: utf-8
class People::TransactionsController < People::BaseController
  # GET /people/transactions
  # GET /people/transactions.json
  def index
    authorize! :index, OrderTransaction
    @transactions = current_order.order("created_at desc").page(params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @transactions }
    end
  end

  # GET /people/transactions/1
  # GET /people/transactions/1.json
  def show
    @transactions = current_order.page params[:page]
    @transaction = current_order.find(params[:id])
    authorize! :show, @transaction
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @transaction }
    end
  end

  def create
    shop_id = params[:product_item][:shop_id]
    @transaction = @people.transactions.build(seller_id: shop_id)
    @transaction.items.build(params[:product_item])
    @transaction.save
    redirect_to person_transactions_path(@people.login),
                  notice: 'Transaction was successfully created.'
  end

  def page
    @transactions = current_order.page params[:page]
    @transaction = current_order.find(params[:id])
    authorize! :show, @transaction
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def event
    @transaction = current_order.find(params[:id])
    event_name = params[:event]
    authorize! :event, @transaction

    if @transaction.buyer_fire_event!(event_name)
      render partial: 'transaction',
                   object:  @transaction,
                   locals: {
                     state:  @transaction.state,
                     people: @people
                   }
    else
      render :json => {message: "#{event_name}不属性你的!"}, :status => 403
      # render :partial => 'transaction', :transaction => @transaction, :layout => false
      # redirect_to person_transaction_path(@people.login, @transaction)
    end
  end

  def batch_create
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

  def base_info
    @transaction = current_order.find(params[:id])
    respond_to do |format|
      @transaction.address = generate_address
      if @transaction.address.valid?
        options = generate_base_option
        if @transaction.update_attributes(options)
          format.json { head :no_content }
        else
          render_address_html
        end
      else
        render_address_html
      end
    end
  end

  def transfer
    @transaction = current_order.find(params[:id])
    respond_to do |format|
      if @transaction.create_transfer(params[:transfer])
        format.json{ head :no_content }
      else
        format.json{ render :json => draw_errors_message(@transfer), :status => 403 }
      end
    end
  end

  def get_delivery_price
    @price = current_order.find(params[:id]).get_delivery_price(params[:delivery_type_id])
    respond_to do |format|
      format.json{ render :json => {delivery_price: @price} }
    end
  end

  def refund
    order = current_order.find(params[:id])
    items = params[:order_refund].delete(:product_items) || []
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
    @transaction = current_order.find(params[:id])
    authorize! :destroy, @transaction
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to person_transactions_path(@people.login) }
      format.json { head :no_content }
    end
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

  private
  def current_order
    OrderTransaction.where(:buyer_id => @people.id)
  end

  def render(*args)
    options = args.extract_options!
    if request.xhr?
      options[:layout] = false
    end

    super *args, options
  end

  def render_address_html
    format.html { render partial: "people/transactions/funcat/address",
                               layout: false,
                               status: '400 Validation Error',
                               locals: {
                                 :transaction => @transaction,
                                 :people => @people }}
  end

  def generate_address
    args = params[:order_transaction]
    if args[:address_id].present?
      Address.find(args[:address_id])
    else
      address = Address.new(gener_address_arg(params[:address]))
      address.user_id = current_user.id
      address.save
      address
    end
  end

  def generate_base_option
    t = params[:order_transaction]
    options = {}
    options[:pay_manner] = get_pay_manner t[:pay_manner_id]
    options[:delivery_manner] = get_delivery_manner t[:delivery_manner_id]
    options[:delivery_type_id] = t[:delivery_type_id]
    options
  end

  def get_pay_manner(pay_manner_id)
    PayManner.find_by(:id => pay_manner_id) || PayManner.default
  end

  def get_delivery_manner(delivery_manner_id)
    DeliveryManner.find_by(:id => delivery_manner_id) || DeliveryManner.default
  end

  def gener_address_arg(a)
    {
      :province_id => a[:province_id],
      :city_id => a[:city_id],
      :area_id => a[:area_id],
      :zip_code => a[:zip_code],
      :road => a[:road]
    }
  end
end
