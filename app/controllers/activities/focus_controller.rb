class Activities::FocusController < Activities::BaseController
	def new
	    @activity = Activity.new
	    @activity.extend(FocusExtension)

	    respond_to do |format|
	      format.html { render :layout => false }
	    end
    end

	def create
		respond_to do |format|
	      if @activity.save
	        format.js { render "activities/add_activity" }
	      else
	        @activity.extend(ScoreExtension)
	        format.js{ render :partial => "activities/auction/form",
	                         :locals  => { :activity => @activity },
	                         :status  => 400 }
	      end
	    end
	end
end


module FocusExtension

  attr_accessor :price, :product, :people_number,:pictrue, 
  				:start, :end, :price, :description

end

