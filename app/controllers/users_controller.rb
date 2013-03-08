class UsersController < ApplicationController

	def index
    	users = User.select(:login)
	    respond_to do | format |
	        format.json { render :json => users }
	    end
	end

end