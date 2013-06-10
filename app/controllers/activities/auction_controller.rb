class Activities::AuctionController < Activities::BaseController

  def new
    @activity = Activity.new
    @activity.extend(AuctionExtension)

    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def create
    activity_params = params[:activity].slice(:product_id, :price, :start_time, :end_time)
    @activity = current_user.activities.build(activity_params)
    @activity.activity_type = "auction"
    @activity.url = "http://lorempixel.com/#{200 + rand(200)}/#{400 + rand(400)}"
    respond_to do |format|
      if @activity.save
        format.js { render "activities/auction/add_activity" }
      else
        @activity.extend(ScoreExtension)
        format.html { render :partial => "activities/auction/form",
                             :locals  => { :activity => @activity },
                             :status  => 400 }
      end
    end
  end
end


module AuctionExtension

  attr_accessor :price, :product, :pictrue, :number, :start_time, :end_time

end
