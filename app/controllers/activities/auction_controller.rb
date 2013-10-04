class Activities::AuctionController < Activities::BaseController

  def new
    @activity = Activity.new
    # @activity.extend(AuctionExtension)

    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def join
    @activity = Activity.find_by(:id => params[:id], :activity_type => :auction)
    @transaction = current_user.transactions.build(seller_id: @activity.shop_id)
    @transaction.items.build({
      :product_id => @activity.shop_product.product_id,
      :amount => params[:product_item][:amount],
      :title => @activity.title,
      :price => @activity.activity_price,
      :buy_state => :guarantee,
      :shop_id => @activity.shop_id,
      :user_id => current_user.id
    })
    @transaction.items.each{|item| item.update_total }
    @activity.activities_participates.build(:user_id => current_user.id)
    respond_to do |format|
      if @transaction.save
        format.js{ render :js => "window.location.href='#{person_transactions_path(current_user)}'" }
        format.html{
          redirect_to person_transactions_path(current_user.login),
                    notice: 'Transaction was successfully created.'
        }
      else
        format.js{ render "/activities/error_join" }
      end
    end
  end

  def create
    slice_options = [:shop_product_id, :price, :start_time, :end_time, :description, :attachment_ids,:title]
    activity_params = params[:activity].slice(*slice_options)

    parse_time!(activity_params)

    @activity = current_user.activities.build(activity_params)
    @activity.activity_type = "auction"
    # @activity.url = "http://lorempixel.com/#{200 + rand(200)}/#{400 + rand(400)}"
    unless activity_params[:attachment_ids].nil?
      @activity.attachments = activity_params[:attachment_ids].map do |k, v|
        Attachment.find_by(:id => v)
      end.compact
    end
    if params[:activity][:activity_price]
      @activity.activity_rules.build(name: 'activity_price',
                                     value_type: 'dvalue',
                                     dvalue: params[:activity][:activity_price])
    end

    respond_to do |format|
      if @activity.save
        format.js { render "activities/add_activity" }
      else
        # @activity.extend(ScoreExtension)
        format.js{ render :partial => "activities/auction/form",
                          :locals  => { :activity => @activity },
                          :status  => 400 }
      end
    end
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
end


# module AuctionExtension

#   attr_accessor  :product, :activity_price

# end
