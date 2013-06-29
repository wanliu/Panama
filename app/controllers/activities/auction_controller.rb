class Activities::AuctionController < Activities::BaseController

  def new
    @activity = Activity.new
    @activity.extend(AuctionExtension)

    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def create
    slice_options = [:product_id, :price, :start_time, :end_time, :description, :attachment_ids]
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
        format.js { render "activities/auction/add_activity" }
      else
        @activity.extend(ScoreExtension)
        format.js { render :partial => "activities/auction/form",
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
          activity_params[field] = date.to_time.in_time_zone
        end
      end
    end
end


module AuctionExtension

  attr_accessor :price, :product, :pictrue, :number, :start_time,
                :end_time, :activity_price, :description

end
