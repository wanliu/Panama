class SearchController < ApplicationController

  def users
    query_val = "%#{params[:q]}%"
    users = User.where("id<>#{current_user.id} and (login like ? or email like ?)", query_val, query_val).limit(params[:limit])
    respond_to do |format|
      _users = users.as_json(methods: :icon).map do |u|
        u["value"] = u["login"]
        u
      end
      format.json{ render :json => _users }
    end
  end

  # def user_shop
  #   query_val = "%#{params[:search_val]}%"
  #   @users = User.where("login like ? or email like ?", query_val, query_val).limit(15)
  #   @shops = Shop.where("name like ?", query_val).limit(15)
  #   respond_to do |format|
  #     format.json{ render json: {users: @users.as_json(methods: :icon), shops: @shops.as_json(methods: :icon_url)} }
  #   end
  # end

end
