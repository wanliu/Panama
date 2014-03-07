#describe: 提醒控制器
class People::NotificationsController < People::BaseController
  before_filter :login_and_service_required

  def index
    authorize! :index, Notification
    @notifications = Notification.unreads
        .where(:user_id => @people.id)
        .order("updated_at desc")

    # @activities = Notification.unreads
    #   .where(:user_id => @people.id, :targeable_type => 'Activity')
    #   .order(updated_at: :asc)

    # @groups = Notification.unreads
    #   .where(:user_id => @people.id, :targeable_type => ['Following', 'PersistentChannel'] )
    #   .order(updated_at: :asc)

    respond_to do | format |
      format.html
      format.json{ render json: @notifications}
    end
  end

  def show
    @notification = Notification.find_by(:user_id => current_user.id, :id => params[:id])
    respond_to do | format |
      unless @notification.nil?
        authorize! :read, @notification
        @notification.update_attribute(:read, true)
        format.html{ redirect_to @notification.url }
        format.json{ head :no_content }
      else
        format.html{ redirect_to person_notifications_path(@people.login) }
      end
    end
  end

  def read_all
    Notification.where(user_id: current_user.id).update_all(read: true)
    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.json { head :no_content }
    end
  end

  def mark_as_read
    @notification = Notification.find(params[:id])
    @notification.change_read
    respond_to do |format|
      format.html { redirect_to @notification.url || person_notifications_path(@people) }
      format.json { render json: @notification.as_json }
    end
  end

  def unreads
    @notifications = Notification.unreads
      .where(:user_id => @people.id)
      .order("updated_at asc")
      .includes(:targeable)
    if params[:offset].present?
      @notifications = @notifications.offset(params[:offset])
    end

    if params[:limit].present?
      @notifications = @notifications.limit(params[:limit])
    end

    respond_to do |format|
      format.json { render json: @notifications.format_unreads(@notifications) }
    end
  end

  def unread_count
    @count = Notification.unreads
      .where(:user_id => @people.id).count
    respond_to do |format|
      format.json{ render json: {count: @count} }
    end
  end
end