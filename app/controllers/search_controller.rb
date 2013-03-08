class SearchController < ApplicationController

    def users
        users = User.where("login like ? or email like ?", "%#{params[:q]}%", "%#{params[:q]}%").limit(params[:limit])
        respond_to do |format|
            _users = users.as_json.map do |u|
                u["user"]["value"] = u["user"]["login"]
                u["user"]
            end
            format.json{ render :json => _users }
        end
    end
end
