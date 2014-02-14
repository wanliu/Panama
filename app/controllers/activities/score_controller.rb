class Activities::ScoreController < Activities::BaseController
	def new
	    @activity = Activity.new
	    @activity.extend(ScoreExtension)

	    respond_to do |format|
	      format.html { render :layout => false }
	    end
    end

	def create
		activity_params = params[:activity].slice!(:product_id, :start_time, :end_time)
		@activity = current_user.activities.build(activity_params)
		@activity.activity_type = "score"
		@activity.url = "http://lorempixel.com/#{200 + rand(200)}/#{400 + rand(400)}"
		respond_to do |format|
			if @activity.save
				format.js { render "activities/score/add_activity" }
			else
				@activity.extend(ScoreExtension)
				format.html { render :partial => "activities/score/form",
														 :locals  => { :activity => @activity },
														 :status  => 400 }
			end
		end
	end
end


module ScoreExtension

  attr_accessor :price, :product, :give_score, :limit_score, :picture, :useableScore, :returnScore, :begin_time, :end_time

end

