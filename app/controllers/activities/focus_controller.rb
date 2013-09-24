class Activities::FocusController < Activities::BaseController

	def new
	    @activity = Activity.new
	    # @activity.extend(FocusExtension)

	    respond_to do |format|
	      format.html { render :layout => false }
	    end
    end

	def create
		slice_options = [:shop_product_id, :people_number, :activity_price, :start_time, :end_time, :attachment_ids, :title]
		activity_params = params[:activity].slice(*slice_options)
    	parse_time!(activity_params)

    	@activity = current_user.activities.build(activity_params)
	    @activity.activity_type = "focus"
	    unless activity_params[:attachment_ids].nil?
	      @activity.attachments = activity_params[:attachment_ids].map do |k, v|
	        Attachment.find_by(:id => v)
	      end.compact
	    end

	    if activity_params[:activity_price] && activity_params[:people_number]
	    	activity_params[:activity_price].map do |key,val|
	    		activity_params[:people_number].map do |key1,val1| 
	    			#value为人数， dvalue为价格
					@activity.activity_rules.build(:name => "activity_price", :value => val, :value_type => "dvalue", :dvalue => val1.to_d ) if key == key1
	    		end
	    	end
	    end


		respond_to do |format|
		    if @activity.save
		        format.js { render "activities/add_activity" }
		    else
		    	format.js{ render :partial => "activities/focus/form",
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
          activity_params[field] = Time.zone.parse(date.to_s)
        end
      end
    end
end


# module FocusExtension

#     attr_accessor :activity_price

# end
