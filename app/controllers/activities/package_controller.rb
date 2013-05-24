class Activities::PackageController < ApplicationController
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

  attr_accessor  :mainProduct,:mainProductPicture,:mainProductPrice,:mainProductNumber,
  	:attachProduct,:attachProductPrice,:attachProductNumber,:attachProductPicture,
  	:attachType
end

