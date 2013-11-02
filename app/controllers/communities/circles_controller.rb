#encoding: utf-8
class Communities::CirclesController < Communities::BaseController

  def index
  end

  def category
    @topics = @circle.topics
    respond_to do |format|
      format.html
      format.json{ render json: @topics }
    end
  end

  def add_category
    @category = @circle.categories.only_deleted.find_by(:name => params[:name])
    if @category.nil?
      @category = @circle.categories.create(:name => params[:name])
    else
      @category.recover
    end
    respond_to do |format|
      if @category.valid?
        format.html
        format.json{ render json: @category }
      else
        format.json{ render json: draw_errors_message(@category), status: 403 }
      end
    end
  end

  def update_category
    @circle_category = @circle.categories.find(params[:category_id])
    @circle_category.update_attributes(:name => params[:name])
    respond_to do |format|
      format.html
      format.json{ render json: @circle_category }
    end
  end

  def del_category
    @circle.categories.find(params[:category_id]).destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def members
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

  def update_circle
    @circle.update_attributes(params[:circle])
    @circle.setting.update_attributes(params[:setting])
    respond_to do |format|
      format.json { head :no_content }
    end
  end 

  def access_denied
  end

  def join
    respond_to do |format|
      unless @circle.limit_join?
        @friend = @circle.join_friend(current_user)
        if @friend.valid?
          format.js{ head :no_content }
        else
          format.js{ render :json => draw_errors_message(@friend), :status => 403  }
        end
      else
        format.js{ render :json => ["商圈需要通过对方同意加入!"], :status => 403  }
      end
    end
  end

  def apply_join
    respond_to do |format|
      if @circle.limit_join?
        @circle.apply_join_notice(current_user)
        format.html{ redirect_to community_access_denied_path(@circle) }
      else
        format.html{ redirect_to community_circles(@circle) }
      end
    end
  end

  def title
    actions, key = t("community.circle"), params[:action].to_sym
    name = "-#{actions[key]}" if actions.key?(key)
    "#{@circle.name}#{name}-商圈"
  end
end