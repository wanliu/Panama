class People::TransactionsController < People::BaseController
  # GET /people/transactions
  # GET /people/transactions.json
  def index
    @transactions = @people.transactions

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @transactions }
    end
  end

  # GET /people/transactions/1
  # GET /people/transactions/1.json
  def show
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @transaction }
    end
  end

  # GET /people/transactions/new
  # GET /people/transactions/new.json
  def new
    @transaction = Transaction.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @transaction }
    end
  end

  # GET /people/transactions/1/edit
  def edit
    @transaction = Transaction.find(params[:id])
  end

  def creates
    trs = {}
    flag = false
    respond_to do |format|
      my_cart.items.each do |item|
        total = item.total
        count = 1
        transaction = trs[item.product.shop.name]
        if transaction.nil? 
          transaction = @people.transactions.build(params[:transaction])
          trs[item.product.shop.name] = transaction
          transaction.seller = item.product.shop
        else
          total = item.total += item.total
          count += item.amount
        end
        transaction.items_count = count
        transaction.total = total
        transaction.items.build item.attributes
      end
      trs.each do |value|
        flag = value.save
      end
      if flag
        my_cart.destroy
        format.html { redirect_to person_transaction_path(@people.login, trs.values.last), notice: 'Transaction was successfully created.' }
        format.json { render json: trs.values.last, status: :created, location: trs.values.last }
      else
        format.html { render action: "new" }
        format.json { render json: trs.values.last.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /people/transactions
  # POST /people/transactions.json
  def create
    @transaction = @people.transactions.build(params[:transaction])

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to person_transaction_path(@people.login, @transaction), notice: 'Transaction was successfully created.' }
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
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
        format.html { redirect_to person_transaction_path(@people.login, @transaction), notice: 'Transaction was successfully updated.' }
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
    @transaction = Transaction.find(params[:id])
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to people_transactions_url }
      format.json { head :no_content }
    end
  end
end
