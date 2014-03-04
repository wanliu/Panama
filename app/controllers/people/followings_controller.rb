#encoding: utf-8
#describe: 关注控制器
class People::FollowingsController < People::BaseController
  # before_filter :login_and_service_required, :except => [:index]
  before_filter :login_required
  # before_filter :person_self_required

  def index
    @u_followings = @people.followings.users
    @s_followings = @people.followings.shops
    respond_to do |format|
      format.html
      format.json{ render json: @people.followings  }
    end
  end

  def shops
    @followings = current_user.followings.shops.includes(:follow)
    respond_to do |format|
      format.html
      format.json{ render json: @followings.map{|f| f.follow.as_json(methods: :icon_url) } }
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

  def unfollow
    @follow = current_user.followings.find_by(follow_type: params[:follow_type], follow_id: params[:follow_id])
    respond_to do |format|
      if @follow.nil?
        format.json{ render :json =>["你没有关注对方！"], :status => 403 }
      else
        @follow.destroy
        format.json{ head :no_content }
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
    # @shop_followers = @people.shop.followers unless @people.shop.nil?  #商店关注者
    respond_to do |format|
      format.html
      format.json{ render :json => @followers }
    end
  end
end
