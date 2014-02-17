#encoding: utf-8
class Communities::NotificationsController < Communities::BaseController
  before_filter :validate_manager
  before_filter :require_member

  def index
  end

  def show
    @notice = @circle.notice.find(params[:id])
    @notice.read_notify
  end

  def agree_join
    @notice = @circle.notice.find(params[:id])
    respond_to do |format|
      @friend = @notice.circle.join_friend(@notice.send_user)
      if @friend.valid?
        @notice.agree(@notice.send_user)
        format.html{ redirect_to community_circles_path(@circle) }
        format.js{ render :js => "window.location.href='#{community_circles_path(@circle)}'"  }
      else
        format.json{ render :json => draw_errors_message(@friend)  }
      end
    end
  end

  def refuse_join
    @notice = @circle.notice.find(params[:id])
    respond_to do |format|
      if @notice.refuse(@notice.send_user)
        format.html{ redirect_to community_circles_path(@circle) }
        format.js{ render :js => "window.location.href='#{community_circles_path(@circle)}'"  }
      end
    end
  end

  def title
    "#{@circle.name}-提醒-商圈"
  end
end