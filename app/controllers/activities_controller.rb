class ActivitiesController < ApplicationController
  before_filter :login_and_service_required
  before_filter :load_category, :only => [:index, :new, :show]
  # layout "activities"
  layout "application"

  respond_to :html, :dialog

  def index
    @activities = Activity.where("status = ?", Activity.statuses[:access])
    @ask_buy = AskBuy.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @activities }
    end
  end

  # GET /activities/1
  # GET /activities/1.json
  def show
    @activity = Activity.find(params[:id])
    @product_item = ProductItem.new({
     :price       => @activity.price,
     :amount      => 1,
     :title       => @activity.description,
     :product_id  => @activity.product_id
    })

    respond_to do |format|
      format.html # show.html.erb
      format.dialog { render "show.dialog", :layout => false }
      format.json {
        render json: @activity.as_json.merge(liked: @activity.likes.exists?(current_user)) }
    end
  end

  def like
    @activity = Activity.find(params[:id])
    @activity.likes.find(current_user)
  rescue ActiveRecord::RecordNotFound
    @activity.likes << current_user
  ensure
    render :text => :OK
  end

  def unlike
    @activity = Activity.find(params[:id])
    @activity.likes.find(current_user)
    @activity.likes.delete(current_user)
    render :text => :OK
  end

  def to_cart
    @item = my_cart.add_to(params[:product_item])
    if @item.save
      render :json => @item
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def join
    @activity = Activity.find(params[:activity][:id])
    @transaction = current_user.transactions.build(seller_id: @activity.shop_id)
    @transaction.items.build({
      :product_id => @activity.shop_product.product_id,
      :amount => params[:product_item][:amount],
      :title => @activity.description,
      :price => @activity.activity_price,
      :buy_state => :guarantee,
      :shop_id => @activity.shop_id,
      :user_id => current_user.id
    })
    @transaction.items.each{|item| item.update_total }
    respond_to do |format|
      if @transaction.save
        format.js{ render :js => "window.location.href='#{person_transactions_path(current_user)}'" }
        format.html{
          redirect_to person_transactions_path(current_user.login),
                    notice: 'Transaction was successfully created.'
        }
      else
        format.js{ render "error_join" }
      end
    end
  end

  # GET /activities/new
  # GET /activities/new.json
  def new
    @activity = Activity.new

    respond_to do |format|
      format.html # new.html.erb
      format.dialog { render :new, layout: false }
      format.json { render json: @activity }
    end
  end

  # GET /activities/1/edit
  def edit
    @activity = Activity.find(params[:id])
  end

  # POST /activities
  # POST /activities.json
  def create
    @activity = Activity.new(params[:activity])

    respond_to do |format|
      if @activity.save
        format.html { redirect_to @activity, notice: 'Activity was successfully created.' }
        format.json { render json: @activity, status: :created, location: @activity }
      else
        format.html { render action: "new" }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /activities/1
  # PUT /activities/1.json
  def update
    @activity = Activity.find(params[:id])

    respond_to do |format|
      if @activity.update_attributes(params[:activity])
        format.html { redirect_to @activity, notice: 'Activity was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1
  # DELETE /activities/1.json
  def destroy
    @activity = Activity.find(params[:id])
    @activity.destroy

    respond_to do |format|
      format.html { redirect_to activities_url }
      format.json { head :no_content }
    end
  end
end
