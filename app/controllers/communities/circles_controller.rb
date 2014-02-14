#encoding: utf-8
class Communities::CirclesController < Communities::BaseController
  before_filter :validate_manager, :only => [:update_circle, :up_to_manager, :low_to_member, :remove_member, :destroy_circle]
  before_filter :require_member, :except => [:apply_join]
  before_filter :member, :only => [:up_to_manager, :low_to_member, :remove_member]

  def index
  end

  def members
    @members = @circle.sort_friends
    respond_to do |format|
      format.html
      format.json{ render json: @members }
    end
  end

  def up_to_manager
    @member.update_attributes(identity: :manage)
    respond_to do |format|
      format.json{ head :no_content}
    end
  end

  def low_to_member
    @member.update_attributes(identity: :member)
    respond_to do |format|
      format.json{ head :no_content}
    end
  end

  def quit_circle
    @circle.remove_friend(current_user)
    # @member = @circle.friends.find_by(:user_id => current_user.id)
    # if @circle.owner.is_a?(Shop)
    #   @circle.owner.notify('/leaved', "#{@member.user.login} 已经离开了你们的商圈 #{@circle.name}", :target => @circle, :avatar => @member.user.icon)
    # elsif @circle.owner.is_a?(User)
    #   @circle.owner.notify('/leaved', "#{@member.user.login} 已经离开了您的商圈 #{@circle.name}", :target => @circle, :avatar => @member.user.icon)
    # end
    # @member.destroy

    respond_to do |format|
      format.json{ head :no_content}
    end
  end

  def remove_member
    @member.destroy
    respond_to do |format|
      format.json{ head :no_content}
    end
  end

  def destroy_circle
    @circle = Circle.find(params[:community_id])
    @circle.destroy
    respond_to do |format|
      format.html { redirect_to communities_path }
    end
  end

  def update_circle
    options = params[:circle]
    if @circle.setting.nil?
      options[:setting] = CircleSetting.create(params[:setting].merge(:circle => @circle))
    else
      @circle.setting.update_attributes(params[:setting])
    end
    @circle.update_attributes(options)
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def access_denied
  end

  def join
    respond_to do |format|
      unless @circle.limit_join? || @circle.limit_city?
        @friend = @circle.join_friend(current_user)
        if @friend.valid?
          format.js{ head :no_content }
        else
          format.js{ render :json => draw_errors_message(@friend), :status => 403  }
        end
      else
        format.js{ render :json => ["商圈需要通过对方同意加入!"], :status => 403  }
      end
    end
  end

  def apply_join
    respond_to do |format|
      if (@circle.limit_city? && @circle.is_limit_city?(current_user)) ||
        (!@circle.limit_city? && @circle.limit_join?)
        @circle.apply_join_notice(current_user)
        format.js{ render :js => "window.location.href='#{community_access_denied_path(@circle)}'" }
        format.html{ redirect_to community_access_denied_path(@circle) }
      else
        format.js{ render :js => "window.location.href='#{community_circles(@circle)}'" }
        format.html{ redirect_to community_circles(@circle) }
      end
    end
  end

  def title
    actions, key = t("community.circle"), params[:action].to_sym
    name = "-#{actions[key]}" if actions.key?(key)
    "#{@circle.name}#{name}-商圈"
  end

  def share_circle
    @circle = Circle.find(params[:community_id])
    unless params[:ids].blank?
      ids = params[:ids]
      if @circle.is_member?(current_user)
        Circle.where(:id => ids).map do |c|
          topic = c.topics.create(:content => @circle.all_detail,
                                  :user => current_user,
                                  :category_id => c.categories.try(:first).try(:id))
          topic.attachments <<  @circle.attachment  unless @circle.attachment.nil?
        end
      end
    end
    respond_to do |format|
      format.json{ head :no_content }
    end
  end

  def member
    @member = @circle.friends.find_by(:user_id => params[:member_id])
  end
end