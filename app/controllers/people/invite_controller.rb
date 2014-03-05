class People::InviteController < People::BaseController
  before_filter :login_and_service_required
  before_filter :person_self_required
  
  def show 
    @invite = shop_invite.find_by_update(params[:id])
  end

  def agree
    @invite = shop_invite.find(params[:id])   
    respond_to do |format|
      @invite.agree_join
      if @invite.targeable.join_employee(current_user)
        @invite.send_user.notify(
          "/people/invite/agree",
          "#{current_user.login}同意你邀请加入企业！",
          :avatar => current_user.icon,
          :targeable => @invite
        )
        format.json{ render :json => @invite.as_json(:include => :targeable) }
      else
        format.json{ render :json => draw_errors_message(@invite), :status => 403 }
      end
    end
  end

  def refuse
    @invite = shop_invite.find(params[:id])
    respond_to do |format|
      @invite.refuse_join
      @invite.send_user.notify(
        "/people/invite/refuse",
        "#{current_user.login}拒绝你邀请加入企业！",
        :avatar => current_user.icon,
        :targeable => @invite
      )
      format.json{ render :json => @invite.as_json(:include => :user) }
    end
  end

  def title
    '雇员-邀请'
  end

  private 
  def shop_invite
    InviteUser.where(:targeable_type => "Shop", :user_id => current_user.id)
  end
end