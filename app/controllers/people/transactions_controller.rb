#encoding: utf-8
class People::TransactionsController < People::BaseController
  # GET /people/transactions
  # GET /people/transactions.json
  def index
    authorize! :index, OrderTransaction
    @transactions = current_order.uncomplete.order("created_at desc").page(params[:page])
    @direct_transactions = current_user.direct_transactions.uncomplete
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @transactions }
    end
  end

  # GET /people/transactions/1
  # GET /people/transactions/1.json
  def show
    @transaction = current_order.find(params[:id])
    authorize! :show, @transaction
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @transaction }
      format.csv{
        send_data(to_csv(OrderTransaction.export_column, @transaction.convert_json),
          :filename => "order#{DateTime.now.strftime('%Y%m%d%H%M%S')}.csv")
      }
    end
  end

  def print
    @transaction = current_order.find(params[:id])
    render :layout => "print"
  end

  def create
    product = Product.find(params[:product_item][:product_id])
    @transaction = @people.transactions.build(seller_id: product.shop_id)
    @transaction.items.build(params[:product_item])
    @transaction.items.each {|item| item.update_total}
    @transaction.save
    redirect_to person_transactions_path(@people.login),
                  notice: 'Transaction was successfully created.'
  end

  def page
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
      @transaction.notice_change_seller(event_name)
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
      if @transaction.address.valid? && @transaction.update_attributes(generate_base_option)
        format.json { render :json => {:event => @transaction.pay_manner.try(:code)} }
      else
        format.html{ render error_back_address_html }
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

  def completed
    @transactions = OrderTransaction.buyer(@people).completed
    @direct_transactions = @people.direct_transactions.completed
  end

  def get_delivery_price
    # @price = current_order.find(params[:id]).get_delivery_price(params[:delivery_type_id])
    @price = DeliveryType.find(params[:delivery_type_id]).try(:price)
    respond_to do |format|
      format.json{ render :json => {delivery_price: @price} }
    end
  end

  def refund
    order, options = current_order.find(params[:id]), params[:order_refund]
    delivery_manner_id = params[:order_refund].delete(:delivery_manner_id)
    if delivery_manner_id.present?
      options.merge!(:delivery_manner =>  DeliveryManner.find(delivery_manner_id))
    end
    respond_to do |format|
      refund = order.refunds.create(options)
      if refund.valid?
        refund.create_items(order.items.map{|item| item.id})
        if refund.items.count <= 0
          refund.destroy
          format.json{ render :json => ["申请退货失败：您选择退货的商品已经在退货之中，或者不能退货"],
                              :status => 403 }
        else
          format.json{ render :json => refund }
        end
      else
        format.json{ render :json => draw_errors_message(refund), :status => 403 }
      end
    end
  end

  def delay_sign
    order = current_order.find(params[:id])
    respond_to do |format|
      if order.current_state_detail.count == 1
        format.json { render json: { text: "no" } }
      elsif order.current_state_detail.delay_sign_expired
        format.json { render json: { text: "ok" } }
      else
        format.json { render json: { text: "fail" } }
      end
    end
  end

  def direct
    @shop_product = ShopProduct.find(params[:shop_product_id])
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

    respond_to do |format|
      if @transaction.close_state?
        @transaction.destroy
        format.html { redirect_to person_transactions_path(@people.login) }
        format.json { head :no_content }
      else
        format.json{ render :state => 403 }
      end
    end
  end

  def dialogue
    @transaction = current_user.transactions.find(params[:id])
    @transaction_message_url = person_transaction_path(current_user, @transaction)
    render :partial => "transactions/dialogue", :layout => "message", :locals => {
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

  def unread_messages
    authorize! :index, OrderTransaction
    @messages = ChatMessage.select("chat_messages.*, cm.count")
               .joins("inner join (select max(id) as id, owner_id, owner_type, count(*) as count
                                      from chat_messages where `read`=0 group by owner_id, owner_type) as cm
                                      on chat_messages.id=cm.id").where("chat_messages.receive_user_id=?", @people.id)

    _messages = @messages.map do |m|
      attrs = m.attributes
      attrs["send_user"] = m.send_user.as_json
      attrs
    end
    respond_to do |format|
      format.json{ render :json => _messages }
    end
  end

  def mark_as_read
    @transaction = Kernel.const_get(params[:owner_type]).find_by(:id => params[:id])
    # if  == "OrderTransaction"
    #   @transaction = current_user.transactions.find(params[:id])
    # else if params[:owner_type] == "DirectTransaction"
    #   @transaction = current_user.direct_transactions.find(params[:id])
    # end
    @url = @transaction.notice_url(current_user)

    @messages = @transaction.messages.unread
    @messages.update_all(read: true)

    respond_to do | format |
      format.json { render json:{:url => @url} }
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

  def error_back_address_html
    { partial: "people/transactions/funcat/address",
      layout: false,
      status: '400 Validation Error',
      locals: { :transaction => @transaction,
                :people => @people } }
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
    options[:delivery_price] = DeliveryType.find(t[:delivery_type_id]).try(:price)
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
      :road => a[:road],
      :contact_name => a[:contact_name],
      :contact_phone => a[:contact_phone]
    }
  end
end
