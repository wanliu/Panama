class Communities::NotificationsController < Communities::BaseController

  def index
  end

  def show
    @notice = CommunityNotification.find(params[:id])
  end

  def agree_join
  end

  def refuse_join
  end
end