class SearchController < ApplicationController

  def users
    query_val = "%#{params[:q]}%"
    users = User.where("id<>#{current_user.id} and (login like ? or email like ?)", query_val, query_val).limit(params[:limit])
    respond_to do |format|
      _users = users.as_json.map do |u|
        u["value"] = u["login"]
        u
      end
      format.json{ render :json => _users }
    end
  end

end
