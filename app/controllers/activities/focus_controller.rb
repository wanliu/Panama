class Activities::FocusController < Activities::BaseController
	def new
	    @activity = Activity.new
	    @activity.extend(FocusExtension)

	    respond_to do |format|
	      format.html { render :layout => false }
	    end
    end

	 def create

	end
end


module FocusExtension

  attr_accessor :price, :product, :people_number,:pictrue, 
  				:start, :end, :price, :description

end

