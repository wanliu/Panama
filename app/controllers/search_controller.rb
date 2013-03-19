class SearchController < ApplicationController

    def users
        users = User.where("login like ? or email like ?", "%#{params[:q]}%", "%#{params[:q]}%").limit(params[:limit])
        respond_to do |format|
            _users = users.as_json(root: false, methods: :icon).map do |u|
                u["value"] = u["login"]
                u
            end
            format.json{ render :json => _users }
        end
    end
end
