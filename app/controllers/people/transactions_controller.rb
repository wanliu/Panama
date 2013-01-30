class People::TransactionsController < People::BaseController
  # GET /people/transactions
  # GET /people/transactions.json
  def index
    @people_transactions = []
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @people_transactions }
    end
  end

  # GET /people/transactions/1
  # GET /people/transactions/1.json
  def show
    @people_transaction = People::Transaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @people_transaction }
    end
  end

  # GET /people/transactions/new
  # GET /people/transactions/new.json
  def new
    @people_transaction = People::Transaction.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @people_transaction }
    end
  end

  # GET /people/transactions/1/edit
  def edit
    @people_transaction = People::Transaction.find(params[:id])
  end

  # POST /people/transactions
  # POST /people/transactions.json
  def create
    @people_transaction = People::Transaction.new(params[:people_transaction])

    respond_to do |format|
      if @people_transaction.save
        format.html { redirect_to @people_transaction, notice: 'Transaction was successfully created.' }
        format.json { render json: @people_transaction, status: :created, location: @people_transaction }
      else
        format.html { render action: "new" }
        format.json { render json: @people_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /people/transactions/1
  # PUT /people/transactions/1.json
  def update
    @people_transaction = People::Transaction.find(params[:id])

    respond_to do |format|
      if @people_transaction.update_attributes(params[:people_transaction])
        format.html { redirect_to @people_transaction, notice: 'Transaction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @people_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/transactions/1
  # DELETE /people/transactions/1.json
  def destroy
    @people_transaction = People::Transaction.find(params[:id])
    @people_transaction.destroy

    respond_to do |format|
      format.html { redirect_to people_transactions_url }
      format.json { head :no_content }
    end
  end
end
