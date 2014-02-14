class Admins::Shops::CommunitiesController < Admins::Shops::SectionController
  def index
    @circles = current_shop.circles
  end

  def people
  end

  def invite_people
    @shop = Shop.find_by(:name => params[:shop_id])
    @user = User.find(params[:user_id])
    ids = params[:ids] unless params[:ids].blank?
    @circles = @shop.circles.where(:id => ids)
    respond_to do |format|
      @circles.each do |circle|
        unless circle.is_member?(@user)
          @invite = circle.invite_users.create(
            :user => @user,
            :send_user => current_user)
          if @invite.valid?
            format.json{ render :json => @invite.as_json(:includes => :user) }
          else
            format.json{ render :json => draw_errors_message(@invite), :status => 403 }
          end
        else
          format.json{ render :json => ["该用户已经加入圈子#{ circle.name}!"], :status => 403 }
        end
      end
    end
  end

  # def apply_join
  #   @cnotification = current_shop_notification.find(params[:cn_id])
  #   @cnotification.read_notify
  # end

  # def join_circle
  #   @cnotification = current_shop_notification.find(params[:cn_id])
  #   @friend = @cnotification.circle.join_friend(@cnotification.send_user)
  #   respond_to do |format|
  #     if @friend.valid?
  #       @cnotification.agree(current_user)
  #       format.json{ head :no_content }
  #     else
  #       format.json{ render :json => draw_errors_message(@friend), :status => 403 }
  #     end
  #   end
  # end

  # def refuse_join
  #   @cnotification = current_shop_notification.find(params[:cn_id])
  #   respond_to do |format|
  #     if @cnotification.refuse(current_user)
  #       format.json{ head :no_content }
  #     else
  #       format.json{ render :json => draw_errors_message(@cnotification), :status => 403 }
  #     end
  #   end
  # end

  # def messages
  #   @notifications = current_shop_notification
  # end

  private

  def current_shop_notification
    CommunityNotification.where(
      :target_id => current_shop.id,
      :target_type => "Shop")
  end

  def current_circle
    Circle.where(
      :owner_id => current_shop.id,
      :owner_type => "Shop")
  end
end