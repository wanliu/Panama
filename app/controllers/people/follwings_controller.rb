#encoding: utf-8
#describe: 关注控制器
class People::FollowingsController < People::BaseController
  before_filter :login_required

  def index
    @followings = current_user.followings
  end

  def user
    user = User.find(params[:user_id])
    @follow = current_user.followings.user(user.id)
    respond_to do | format |
      if @follow.valid?
        form.html
        form.json{ render :json => @follow }
      else
        form.json{ render :json => draw_errors_message(@follow), :status => 403 }
      end
    end
  end

  def shop
    shop = Shop.find(params[:shop_id])
    @follow = current_user.followings.shop(shop.id)
    respond_to do | format |
      if @follow.valid?
        form.html
        form.json{ render :json => @follow }
      else
        form.json{ render :json => draw_errors_message(@follow), :status => 403 }
      end
    end
  end


end
