class Admins::Shops::CommunitiesController < Admins::Shops::SectionController
  def index
    @circles = current_shop.circles
  end

  def people
  end

  def apply_join
    @cnotification = current_shop_notification.find(params[:cn_id])
    @cnotification.read_notify
  end

  def join_circle
    @cnotification = current_shop_notification.find(params[:cn_id])
    @friend = @cnotification.circle.join_friend(@cnotification.send_user)
    respond_to do |format|
      if @friend.valid?
        format.json{ head :no_content }
      else
        format.json{ render :json => draw_errors_message(@friend), :status => 403 }
      end
    end
  end

  def refuse_join
    @cnotification = current_shop_notification.find(params[:cn_id])
    @cnotification.state = true
    respond_to do |format|
      if @cnotification.save
        format.json{ head :no_content }
      else
        format.json{ render :json => draw_errors_message(@cnotification), :status => 403 }
      end
    end
  end

  def messages
    @notifications = current_shop_notification
  end

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