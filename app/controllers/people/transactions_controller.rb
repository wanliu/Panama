#encoding: utf-8
class People::TransactionsController < People::BaseController
  before_filter :login_required, :except => [:kuaiqian_receive]
  helper_method :base_template_path

  def index
    authorize! :index, OrderTransaction
    @transactions = current_order.uncomplete.order("created_at desc").page(params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @transactions }
    end
  end

  def show
    @transaction = current_order.find(params[:id])
    @pay_msg = params[:pay_msg]
    authorize! :show, @transaction
    respond_to do |format|
      format.html
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
      render partial: 'transaction',
             object:  @transaction,
             locals: {
                state:  @transaction.state,
                people: @people
              }
    else
      render :json => {message: "#{event_name}不属于你的!"}, :status => 403
      # render :partial => 'transaction', :transaction => @transaction, :layout => false
      # redirect_to person_transaction_path(@people.login, @transaction)
    end
  end

  def batch_create
    authorize! :batch_create, OrderTransaction
    item_ids = params[:items].map{ |k, v| 
      v[:id].to_i if v[:checked] == 'on' }.compact
          
    if my_cart.create_transaction(@people, item_ids)
      redirect_to person_transactions_path(@people.login),
                  notice: 'Transaction was successfully created.'
    else
      # FIXME
      redirect_to person_cart_index_path(@people.login),
                  notice: 'We are sorry, but the transaction was not successfully created.'
    end
  end

  def kuaiqian_payment
    @transaction = current_order.find(params[:id])
    options = {
      :bg_url => paid_send_url,
      :payer_name => current_user.login,
      :order_id => @transaction.number,
      :order_amount => (@transaction.stotal * 100).to_i,
      :product_name => @transaction.items[0].title,
      :product_num => @transaction.items_count,
      :order_time => Time.now.strftime("%Y%m%d%H%M%S")
    }
    options.merge!(:pay_type => "10",
      :bank_id => params[:bank]) if params[:bank].present?
    pay_ment = KuaiQian::PayMent.request(options)
    respond_to do |format|
      format.js{ render :js => "window.location.href='#{pay_ment.url}'" }
      format.html{ redirect_to pay_ment.url }
    end
  end

  def kuaiqian_receive
    _response = KuaiQian::PayMent.response(params)
    @transaction = current_order.find(params[:id])
    url = if _response.successfully?
      @transaction.kuaiqian_paid
      "#{paid_receive_url}?pay_msg=success"
    else
      "#{paid_receive_url}?pay_msg=error"
    end
    render :xml => {:result => "1", :redirecturl => url }
  end

  def test_payment
    @transaction = current_order.find(params[:id])
    @transaction.kuaiqian_paid if payment_mode?
    respond_to do |format|
      url = "#{person_transaction_path(@people, @transaction)}?pay_msg=success"
      format.html{
        redirect_to url }
      format.js{ render :js => "window.location.href='#{url}'" }
    end
  end

  def base_info
    @transaction = current_order.find(params[:id])
    respond_to do |format|
      @transaction.address = generate_address
      if @transaction.address.valid? &&
        @transaction.update_attributes(params[:order_transaction])
        format.json { render :json => {:event => @transaction.pay_type_name} }
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
    @transactions = OrderTransaction.buyer(@people).completed.order("created_at desc").page(params[:page])
    @direct_transactions = @people.direct_transactions.completed.order("created_at desc").page(params[:page])
  end

  def refund
    order, options = current_order.find(params[:id]), params[:order_refund]
    respond_to do |format|
      refund = order.refunds.create(options)
      if refund.valid?
        refund.create_items(order.items.pluck("id"))
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
    @message = @transaction.message_create(
      params[:message].merge(
        send_user: current_user,
        receive_user: @transaction.current_operator))

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
                           .joins("inner join (select max(id) as id, owner_id, owner_type, count(*) as count from chat_messages where `read`=0 group by owner_id, owner_type) as cm on chat_messages.id=cm.id")
                           .where("chat_messages.receive_user_id=?", @people.id)

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
    @transaction = Module.const_get(params[:owner_type]).find_by(:id => params[:id])
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
    address_id = args.delete(:address_id)
    if address_id.present?
      DeliveryAddress.find(address_id)
    else
      current_user.delivery_addresses.create(gener_address_arg(params[:address]))
    end
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

  def paid_receive_url
    "#{Settings.site_url}#{person_transaction_path(@people, @transaction)}"
  end

  def paid_send_url
    "#{Settings.site_url}#{kuaiqian_receive_person_transaction_path(current_user, @transaction)}"
  end

  def base_template_path
    "people/transactions/base"
  end
end
