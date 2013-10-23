class Activities::FocusController < Activities::BaseController

  def new
    @activity = Activity.new
    # @activity.extend(FocusExtension)
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def create
    slice_options = [:shop_product_id, :people_number, :activity_price, :start_time, :end_time, :attachment_ids, :title]
    activity_params = params[:activity].slice(*slice_options)

    parse_time!(activity_params)

    @activity = current_user.activities.build(activity_params)
    @activity.activity_type = "focus"
    unless activity_params[:attachment_ids].nil?
      @activity.attachments = activity_params[:attachment_ids].map do |k, v|
        Attachment.find_by(:id => v)
      end.compact
    end

    activity_params[:people_number].each do |i, people_number|
      unless people_number.blank? || activity_params[:activity_price][i].blank?
        #value为人数， dvalue为价格
        @activity.activity_rules.build(:name => "activity_price", :value => people_number, :value_type => "dvalue", :dvalue => activity_params[:activity_price][i].to_d )
      end
    end

    respond_to do |format|
      if @activity.save
        format.js { render "activities/add_activity" }
      else
        format.js{  render :partial => "activities/focus/form",
                   :locals  => { :activity => @activity },
                   :status  => 400 }
      end
    end
  end

  def join
    @activity = focus_activity.find_by(:id => params[:id])
    address = params[:address]
    @transaction = current_user.transactions.build(seller_id: @activity.shop_id)
    @product_item = @transaction.items.build({
      :product_id => @activity.shop_product.product_id,
      :amount => params[:product_item][:amount],
      :title => @activity.title,
      :price => @activity.focus_price,
      :buy_state => :guarantee,
      :shop_id => @activity.shop_id,
      :user_id => current_user.id
    })
    @transaction.pay_manner = PayManner.find(params[:pay_manner_id])
    @transaction.address = delivery_address(address)
    @transaction.items.each{|item| item.update_total }
    respond_to do |format|
      if @transaction.save
        @transaction.buyer_fire_event!("buy")
        format.js{ render :js => "window.location.href='#{person_transactions_path(current_user)}'" }
        format.html{
          redirect_to person_transactions_path(current_user.login),
                    notice: 'Transaction was successfully created.'
        }
      else
        format.html{ render :partial => "/activities/auction/buy.dialog", :status => 403 }
      end
    end
  end

  def unjoin
    @activity = Activity.find(params[:id])
    begin
      @activity.participates.delete(current_user)
    rescue ActiveRecord::RecordNotFound
    end
    render :text => :OK
  end

  private
  def parse_time!(activity_params)
    [:start_time, :end_time].each do |field|
      unless activity_params[field].blank?
        date = Date.strptime(activity_params[field], '%m/%d/%Y')
        activity_params[field] = Time.zone.parse(date.to_s)
      end
    end
  end

  def focus_activity
    Activity.where(:activity_type => "focus")
  end

  def delivery_address(address)
    if address[:id].present?
      current_user.delivery_addresses.find(address[:id])
    else
      current_user.delivery_addresses.create(address)
    end
  end
end