class Activities::ScoreController < ApplicationController
	def new
	    @activity = Activity.new
	    @activity.extend(ScoreExtension)

	    respond_to do |format|
	      format.html { render :layout => false }
	    end
    end

	def create
		params
		debugger
		self
	end
end


module ScoreExtension

  attr_accessor :price, :product, :give_score, :limit_score, :picture, :useableScore, :returnScore, :begin_time, :end_time

end

