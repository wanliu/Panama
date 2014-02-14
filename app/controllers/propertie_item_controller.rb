class PropertieItemController < ApplicationController

	# DELETE /propertie_item/1
 	# DELETE /propertie_item/1.json
	def destroy 
		@item = PropertyItem.find(params[:id])
		@item.destroy

		render :json => {success: true}
	end
end