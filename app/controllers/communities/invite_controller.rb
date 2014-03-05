#encoding: utf-8
class Communities::InviteController < Communities::BaseController
  before_filter :validate_manager, :only => :create

  def new
    respond_to do |format|
      format.html{ render :layout => false  }
    end
  end

  def show
    @invite = current_invite
    @invite.read_notify
  end

  def create
    login = params[:invite].delete(:login)
    @user = User.find_by(login: login)
    respond_to do |format|
      if @user.present?
        unless @circle.is_member?(@user)
          @invite = @circle.invite_users.create(params[:invite].merge({
              :user => @user,
              :send_user => current_user
            }))
          if @invite.valid?
            format.json{ render :json => @invite.as_json(:includes => :user) }
          else
            format.json{ render :json => draw_errors_message(@invite), :status => 403 }
          end
        else
          format.json{ render :json => ["该用户已经加入!"], :status => 403 }
        end
      else
        format.json{ render :json => ["该用户不存在！"], :status => 403 }
      end
    end
  end

  def agree_join
    @invite = current_invite
    respond_to do |format|
      if @invite.agree_join
        @circle.join_friend(@invite.user)
        format.js{
          render :js => "window.location.href='#{community_circles_path(@circle)}'" }
        format.html{
          redirect_to community_circles_path(@circle)
        }
        format.json{ head :no_content}
      else
        format.js{
          render :js => "pnotify({text: '出错了！'})" }
      end
    end
  end

  def refuse_join
    @invite = current_invite
    respond_to do |format|
      if @invite.refuse_join
        format.js{ render :js => "window.location.href='#{person_communities_path(@current_user)}'" }
        format.html{
          redirect_to person_communities_path(@current_user)
        }
        format.json{ head :no_content}
      else
        format.js{
          render :js => "pnotify({text: '出错了！'})" }
      end
    end
  end

  def title
    "#{@circle.name}-邀请-商圈"
  end

  private
  def current_invite
    @circle.invite_users.find(params[:id])
  end
end