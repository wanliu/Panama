class Activities::FocusController < Activities::BaseController
	def new
	    @activity = Activity.new
	    @activity.extend(FocusExtension)

	    respond_to do |format|
	      format.html { render :layout => false }
	    end
    end

	def create
		slice_options = [:shop_product_id,:people_number, :price, :start_time, :end_time, :attachment_ids]
		activity_params = params[:activity].slice(*slice_options)
    	parse_time!(activity_params)


    	@activity = current_user.activities.build(activity_params)
	    @activity.activity_type = "focus"
	    unless activity_params[:attachment_ids].nil?
	      @activity.attachments = activity_params[:attachment_ids].map do |k, v|
	        Attachment.find_by(:id => v)
	      end.compact
	    end

    	activity_params[:price].map do |key,val|
    		activity_params[:people_number].map do |key1,val1| 
				@activity.price_lists <<  PriceList.create(:price => val, :people_number => val1) if key == key1
    		end
    	end
		respond_to do |format|
		    if @activity.save(:validate => false)
		        format.js { render "activities/add_activity" }
		    # else
		    #     # @activity.extend(ScoreExtension)
		    #     format.js{ render :partial => "activities/focus/form",
		    #                       :locals  => { :activity => @activity },
		    #                       :status  => 400 }
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


module FocusExtension

  attr_accessor :price, :product, :people_number,:pictrue, 
  				:start, :end, :price, :description

end