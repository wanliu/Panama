#encoding: utf-8
class People::CirclesController < People::BaseController

  def index
    @circles = @people.all_circles
    @circles = @circles.map do |circle|
      c = circle.as_json
      c[:isOwner] = circle.is_owner_people?(current_user)
      c[:isJoin] = circle.is_member?(current_user)
      c[:friend_count] = circle.friend_count
      c
    end
    respond_to do |format|
      format.json{ render json: @circles }
    end
  end

  def create
    @circle = @people.circles.create(params[:circle])
    respond_to do |format|
      if @circle.valid?
        format.json{ render json: @circle }
      else
        format.json{ render json: draw_errors_message(@circle), status: 403 }
      end
    end
  end

  def show
    @circle = @people.all_circles.find_by(:id => params[:id])
    respond_to do |format|
      format.html{ render :partial => "/circles/circle_setting", :locals => { :circle => @circle }}
    end
  end

  def friends
    @users = @people.circles.find(params[:circle_id]).friend_users
    respond_to do |format|
      format.json{ render json: @users.as_json }
    end
  end

  #获取把你加入的圈子对象
  def addedyou
    circle_ids = @people.circle_friends.map{|c| c.circle_id }
    @circles = Circle.where(:id => circle_ids).includes(:owner)
    data = @circles.map do |c|
      c.owner.as_json.merge(owner_type: c.owner_type, circle_id: c.id)
    end
    respond_to do |format|
      format.json{ render json: data }
    end
  end

  #所有的好友
  def all_friends
    @users = @people.circle_all_friends.joins(:user).map{|f| f.user.as_json }
    respond_to do |format|
      format.json{ render json: @users }
    end
  end

  #加入好友
  def join_friend
    @circle = @people.circles.find(params[:id])
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

  #移除某个圈子的某个用户
  def remove_friend
    @circle = current_user.all_circles.find(params[:id])
    respond_to do |format|
      url = "/people/#{current_user.login}/communities/show_members/#{@circle.id}"
      if @circle.remove_friend(params[:user_id])
        flash[:success] = " 删除成员成功"
        format.json{ head :no_content }
        format.html{ redirect_to url}
      else
        flash[:success] = "删除失败"
        format.json{ render json: {message: "删除失败!"}, status: 403 }
        format.json{ redirect_to url }
      end
    end
  end

  #移除所有圈子中的某个好友
  def circles_remove_friend
    @friends = current_user.circle_all_friends.where(user_id: params[:user_id])
    @friends.destroy_all
    respond_to do |format|
      format.json{  head :no_content  }
    end
  end

  def destroy
    @circle = @people.circles.find(params[:id])
    @circle.destroy
    respond_to do |format|
      format.json{ head :no_content }
    end
  end

  def apply_join
    @circle = Circle.find(params[:id])
    friend = @circle.friends.build(:user_id => @people.id)
    respond_to do |format|
      if friend.valid?
        if @circle.limit_join?
          @circle.apply_join_notice(@people)
          format.json{ render json:{ message: "请求已经发送~~~",type: "waiting" }}
        else
          if friend.save
            format.json{ render json:{ message: "成功加入该圈~~~",type: "success" }}
          else
            format.json{ render json:{ message: draw_errors_message(friend)}, status: 403}
          end
        end
      else
        format.json{ render json:{ message: draw_errors_message(friend)}, status: 403}
      end
    end
  end

  private
  def circle_find_user(user_id, circle)
    circle.friends.find_by(user_id: user_id)
  end

  def encrypt(login)
    Crypto.encrypt(login)
  end
end
