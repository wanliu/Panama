#encoding: utf-8
class Admins::Shops::CirclesController < Admins::Shops::SectionController

  def index
    @circles = current_shop.circles
    respond_to do |format|
      format.json{ render json: @circles.as_json(methods: :friend_count) }
    end
  end

  def create
    begin
      Circle.transaction do
        @circle = current_shop.circles.create(
          params[:circle].merge({ 
            created_type: "advance", 
            city_id: params[:address][:area_id], 
            setting_id: CircleSetting.create(params[:circle][:setting]).id 
        }))
      end
    rescue Exception => ex
    end

    respond_to do |format|
      if @circle.valid?
        format.json{ render json: @circle }
      else
        format.json{ render json: draw_errors_message(@circle), status: 403 }
      end
    end
  end

  def show
    @circles = current_shop.circles
    @circle = current_shop.circles.find(params[:id])
    respond_to do |format|
      format.html
      format.json{ render json: @circle }
    end
  end

  def edit
    @circle = current_shop.circles.find(params[:id])
    ancestor_ids = @circle.city.ancestor_ids
    @address = Address.new({ province_id: ancestor_ids[1], city_id: ancestor_ids[2], area_id: @circle.city_id })
    render layout: false
  end

  def update
    @circle = current_shop.circles.find(params[:id])
    begin
      Circle.transaction do
        @circle.update_attributes(params[:circle].merge({city_id: params[:address][:area_id]}))
        @circle.setting.update_attributes(params[:circle][:setting])
      end
    rescue Exception => ex
    end

    respond_to do |format|
      if @circle.valid?
        format.json{ render json: @circle }
      else
        format.json{ render json: draw_errors_message(@circle), status: 403 }
      end
    end
  end

  #加入好友
  def join_friend
    @circle = current_shop.circles.find(params[:id])
    respond_to do |format|
      if circle_find_user(params[:user_id], @circle).nil?
        if @circle.join_friend(params[:user_id]).valid?
          format.json{ render json: circle_find_user(params[:user_id], @circle).user }
        else
          format.json{ render json: {message: "加入失败！"}, status: 403 }
        end
      else
        format.json{ render json: {message: "已经存在好友了!"}, status: 403 }
      end
    end
  end

  def friends
    @users = current_shop.circles.find(params[:circle_id]).friend_users
    respond_to do |format|
      format.json{ render json: @users.as_json }
    end
  end

  #移除某个圈子的某个用户
  def remove_friend
    @circle = current_shop.circles.find(params[:id])
    respond_to do |format|
      if @circle.remove_friend(params[:user_id])
        format.json{ head :no_content }
      else
        format.json{ render json: {message: "删除失败!"}, status: 403 }
      end
    end
  end

  #移除某个用户所有圈子的这个好友
  def circles_remove_friend
    @friends = current_shop.circle_all_friends.where(user_id: params[:user_id])
    @friends.destroy_all
    respond_to do |format|
      format.json{  head :no_content  }
    end
  end

  #所有的好友
  def all_friends
    @users = current_shop.circle_all_friends.joins(:user).map{|f| f.user.as_json }
    respond_to do |format|
      format.json{ render json: @users }
    end
  end

  def followers
    @users = current_shop.followers.joins(:user).map{|f| f.user}
    respond_to do |format|
      format.json{ render json: @users }
    end
  end

  def destroy
    @circle = current_shop.circles.find(params[:id])
    @circle.destroy
    respond_to do |format|
      format.json{ head :no_content }
    end
  end

  private
  def circle_find_user(user_id, circle)
    circle.friends.find_by(user_id: user_id)
  end
end