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
    @category = @circle.categories.only_deleted.find_by(:name => "反馈")
    if @category.nil?
      @category = @circle.categories.create(:name => params[:name])
    else
      @category.recover
    end
    respond_to do |format|
      if @category.valid
        format.html
        format.json{ render json: @category }
      else
        format.json{ render json: draw_errors_message(@category), status: 403 }
      end
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

end