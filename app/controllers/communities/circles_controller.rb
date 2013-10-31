#encoding: utf-8
class Communities::CirclesController < Communities::BaseController

  def index
  end

  def category
    @topics = Topic.where(:circle_id => params[:community_id],:category_id => params[:category_id])
    respond_to do |format|
      format.html
      format.json{ render json: @topics }
    end
  end

  def add_category
	  @circle = Circle.find(params[:community_id])
	  @circle_category = @circle.categories.create(:name => params[:name])
	  respond_to do |format|
	    format.html
	    format.json{ render json: @circle_category }
	  end
  end

  def del_category
    @circle = Circle.find(params[:community_id])
    @circle.categories.find(params[:category_id]).delete
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def members
    @circle = Circle.find(params[:community_id])
    @members = @circle.friend_users
    respond_to do |format|
      format.html
      format.json{ render json: @members }
    end
  end

  def title
    actions, key = t("community.circle"), params[:action].to_sym
    name = "-#{actions[key]}" if actions.key?(key)
    "#{@circle.name}#{name}-商圈"
  end

end