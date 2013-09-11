#encoding: utf-8

ActiveAdmin.register Activity do

  scope :等待审核, default: true do
    Activity.where("status = ?", Activity.statuses[:wait])
  end

  scope :被驳回 do
    Activity.where("status = ?", Activity.statuses[:rejected])
  end

  scope :已审核通过 do
    Activity.where("status = ?", Activity.statuses[:access])
  end

  index do
    column :id
    column "预览图" do |row|
      if row.attachments.length > 0
        image_tag row.attachments.first.file.url("100x100")
      end
    end
    column :description
    column :author
    default_actions
  end

  show do
    render "check_info"
  end

  action_item  do
    link_to "排承", schedule_sort_system_activities_path                
  end

  collection_action :schedule_sort, :method => :get do 
  end

  collection_action :schedule_sort1, :method => :get do 
    start = Time.at(params[:start].to_i) unless params[:start].nil?
    _end = Time.at(params[:end].to_i) unless params[:end].nil?
    @activities = Activity.where("start_time >= ? AND end_time <= ?", start, _end)
    respond_to do |format|
      format.json { render json: @activities }
    end
  end

  member_action :modify, :method => :post do
    activity = Activity.find(params[:id])
    activity.update_attributes(
      :start_time => Time.parse(params[:start_time]),
      :end_time => Time.parse(params[:end_time])
    )
    debugger
    respond_to do |format|
      format.json{  head :no_content  }
    end
  end

  member_action :check, method: :post do
    activity = Activity.find(params[:id])
    activity.update_attributes(status: Activity.statuses[:access])
    activity.send_checked_mail
    activity.notice_author(current_user, "您发布的活动已经通过审核")
    activity.notice_followers
    redirect_to action: :index
  end

  member_action :reject, method: :post do
    activity = Activity.find(params[:id])
    activity.update_attributes(status: Activity.statuses[:rejected], rejected_reason: params[:reject_reason])
    activity.send_rejected_mail
    activity.notice_author(current_user, "您发布的活动没有通过审核")
    redirect_to action: :index
  end
end