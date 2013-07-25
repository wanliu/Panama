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

  def products
    query = params[:q]
    s = Tire.search 'products' do 
        # query do 
        #   string "name:#{query}"
        # end

        constant_score do 
          query do 
            string "name:#{query}"
          end

          boost 1.2
        end
        size 30

        # analyzer　:standard
      end
    respond_to do |format|
      format.json { render :json => s.results }
    end
  end
end
