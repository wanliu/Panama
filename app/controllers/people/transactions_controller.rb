class People::TransactionsController < People::BaseController
  # GET /people/transactions
  # GET /people/transactions.json
  def index
    authorize! :index, OrderTransaction
    @transactions = OrderTransaction.where(:buyer_id => @people.id).page(params[:page])
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
    authorize! :event, @transaction
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

  # GET /people/transactions/new
  # GET /people/transactions/new.json
  def new
    @transaction = OrderTransaction.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @transaction }
    end
  end

  # GET /people/transactions/1/edit
  def edit
    @transaction = OrderTransaction.find(params[:id])
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

  # PUT /people/transactions/1
  # PUT /people/transactions/1.json
  def update
    @transaction = OrderTransaction.find(params[:id])
    respond_to do |format|
      if @transaction.update_attributes(params[:order_transaction])
        format.html { redirect_to person_transaction_path(@people.login, @transaction), notice: 'OrderTransaction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit", :layout => false }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  def address
    @transaction = OrderTransaction.find(params[:id])
    respond_to do |format|
      address_params = params[:address]
      address_id = params[:order_transaction][:address_id]
      if address_id.present?
        @transaction.update_attribute(:address_id, address_id)
        format.html { render :text => :OK }
      else
        @transaction.create_address(address_params)
        if @transaction.save
          # format.html { redirect_to person_transaction_path(@people.login, @transaction), notice: 'OrderTransaction was successfully updated.' }
          format.html { render partial: "address",
                               layout: false,
                               locals: {
                                 transaction: @transaction,
                                 :people => @people }}
        else
          format.html { render partial: "address",
                               layout: false,
                               status: '400 Validation Error',
                               locals: {
                                 transaction: @transaction,
                                 :people => @people }}
        end
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
    receive_user = @transaction.current_operator
    @transaction.buyer_send_message()
    # @message = @transaction.message_create(
    #   params[:message].merge(
    #     receive_user: receive_user,
    #     send_user: current_user))

    respond_to do |format|
      format.json{ render :json => @message }
    end
  end

  def messages
    @transaction = current_user.transactions.find(params[:id])
    respond_to do |format|
      format.json{ render :json => @transaction.messages  }
    end
  end
end
