class Activities::CourageController < Activities::BaseController
	def new
	    @activity = Activity.new
	    @activity.extend(CourageExtension)

	    respond_to do |format|
	      format.html { render :layout => false }
	    end
    end

	 def create

	end
end


module CourageExtension

  attr_accessor :price, :product,:picture,:number
end

