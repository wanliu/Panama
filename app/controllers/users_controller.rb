class UsersController < ApplicationController

	def index		
    	users = User.where("login like ?", "%#{params[:q]}").select(:login)
    	# users = User.select(:login)
	    respond_to do | format |
	        format.json { render :json => users.map{|u| {login: u.login} } }
	    end
	end

end