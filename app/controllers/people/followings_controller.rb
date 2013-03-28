#encoding: utf-8
#describe: 关注控制器
class People::FollowingsController < People::BaseController
  before_filter :login_required, :except => [:index]

  def index
    @u_followings = @people.followings.users
    @s_followings = @people.followings.shops
    respond_to do |format|
      format.html
      format.json{ render :json => @followings }
    end
  end

  def user
    authorize! :user, Following
    user = User.find(params[:user_id])
    @follow = current_user.followings.user(user.id)
    respond_to do | format |
      if @follow.valid?
        format.html
        format.json{ render :json => @follow }
      else
        format.json{ render :json => draw_errors_message(@follow), :status => 403 }
      end
    end
  end

  def shop
    authorize! :shop, Following
    shop = Shop.find(params[:shop_id])
    @follow = current_user.followings.shop(shop.id)
    respond_to do | format |
      if @follow.valid?
        format.html
        format.json{ render :json => @follow }
      else
        format.json{ render :json => draw_errors_message(@follow), :status => 403 }
      end
    end
  end

  def destroy
    @follow = current_user.followings.find_by(id: params[:id])
    authorize! :destroy, @follow
    @follow.destroy
    respond_to do | format |
      format.html
      format.json{ head :no_content }
    end
  end

  def followers
    @followers = @people.followers
    respond_to do |format|
      format.html
      format.json{ render :json => @followers }
    end
  end
end
