class Activities::ScoreController < ApplicationController
	def new
	    @activity = Activity.new
	    @activity.extend(ScoreExtension)

	    respond_to do |format|
	      format.html { render :layout => false }
	    end
    end

	 def create

	end
end


module ScoreExtension

  attr_accessor :price, :product,:picture,:useableScore,:returnScore,:begin_time,:end_time

end

