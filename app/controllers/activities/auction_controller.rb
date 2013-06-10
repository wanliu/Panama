class Activities::AuctionController < Activities::BaseController

  def new
    @activity = Activity.new
    @activity.extend(AuctionExtension)

    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def create

  end
end


module AuctionExtension

  attr_accessor :price, :product,:pictrue, :number

end
