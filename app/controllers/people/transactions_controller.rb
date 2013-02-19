class People::TransactionsController < People::BaseController
  # GET /people/transactions
  # GET /people/transactions.json
  def index
    @transactions = OrderTransaction.where(:buyer_id => @people).page params[:page]

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

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @transaction }
    end
  end

  def event
    @transaction = OrderTransaction.find(params[:id])
    if @transaction.fire_events!(params[:event])
      redirect_to person_transaction_path(@people.login, @transaction)
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
    flag = false
    my_cart.items.group_by { |item| item.product.shop }.each do |shop, items|
      transaction = @people.transactions.build seller_id: shop.id
      items.each {|item| transaction.items.build item.attributes }
      transaction.items_count = items.inject(0) { |s, item| s + item.amount }
      transaction.total = items.inject(0) { |s, item| s + item.total }
      flag = transaction.save
      # if flag
      #   items.destroy
      # end
    end
    if flag
      my_cart.destroy
    end
    redirect_to person_transactions_path(@people.login), 
                notice: 'OrderTransaction was successfully created.'
  end

  # POST /people/transactions
  # POST /people/transactions.json
  def create
    @transaction = @people.transactions.build(params[:transaction])

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
      if @transaction.update_attributes(params[:transaction])
        format.html { redirect_to person_transaction_path(@people.login, @transaction), notice: 'OrderTransaction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/transactions/1
  # DELETE /people/transactions/1.json
  def destroy
    @transaction = OrderTransaction.find(params[:id])
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to people_transactions_url }
      format.js
      format.json { head :no_content }
    end
  end
end
