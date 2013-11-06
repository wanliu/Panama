class Communities::NotificationsController < Communities::BaseController

  def index
  end

  def show
    @notice = @circle.notice.find(params[:id])
  end

  def agree_join
    @notice = @circle.notice.find(params[:id])
    respond_to do |format|
      @friend = @notice.circle.join_friend(@notice.send_user)
      if @friend.valid?
        @notice.agree(current_user)
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
      if @notice.refuse(current_user)
        format.html{ redirect_to community_circles_path(@circle) }
        format.js{ render :js => "window.location.href='#{community_circles_path(@circle)}'"  }
      end
    end
  end

  def title
    actions, key = t("community.notifications"), params[:action].to_sym
    name = "-#{actions[key]}" if actions.key?(key)
    "#{@circle.name}#{name}-商圈"
  end
end