class Activities::PackageController < Activities::BaseController
	def new
	    @activity = Activity.new
	    @activity.extend(PackageExtension)

	    respond_to do |format|
	      format.html { render :layout => false }
	    end
    end

	 def create

	end
end


module PackageExtension

  attr_accessor  :main_product, :main_product_price,
  				 :main_product_number, :attach_product, :attach_product_price,
  				 :attach_product_number, :attach_type
end

