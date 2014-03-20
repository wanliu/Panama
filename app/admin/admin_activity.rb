#encoding: utf-8

ActiveAdmin.register Activity do
  config.clear_action_items!
  form :partial => "form"

  actions :all, :except => [:new]

  scope :等待审核, default: true do
    Activity.where("status = ?", Activity.statuses[:wait])
  end

  scope :未通过 do
    Activity.where("status = ?", Activity.statuses[:rejected])
  end

  scope :已通过 do
    Activity.where("status = ?", Activity.statuses[:access])
  end

  index do
    column :id
    column "预览图" do |row|
      if row.attachments.length > 0
        image_tag row.attachments.first.file.url("100x100")
      end
    end
    column :title
    column '商店' do |a|
      a.shop.try(:name)
    end
    column :author

    column "操作" do |c|
      link_1 = link_to "查看", system_activity_path(c), :class =>"member_link"
      if c.status == Activity.statuses[:wait]
        link_2 = link_to "编辑", edit_system_activity_path(c), :class =>"member_link"
        link_3 = link_to "删除", system_activity_path(c), :method => :delete, :confirm => "确定删除吗？", :class =>"member_link"
      end
      link_1 + (link_2 || "") + (link_3 || "")
    end
  end

  show do
    @activity = Activity.find(params[:id])
    render "check_#{@activity.activity_type}"
  end

  action_item do
    if params[:action] == "show"
      if activity.status == Activity.statuses[:wait]
        link = link_to "编辑活动", edit_system_activity_path(activity)
      end
    end
    (link || "")
  end

  action_item  do
    link_to "排程日历", schedule_sort_system_activities_path
  end

  action_item  do
    link_to "返回", system_activities_path
  end

  collection_action :schedule_sort, :title => "活动日历", :method => :get do
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
      :start_time => Time.parse(params[:start]),
      :end_time => Time.parse(params[:end])
    )
    respond_to do |format|
      format.json{  head :no_content  }
    end
  end

  action_item do
    if params[:action] == "show"
      if activity.status == Activity.statuses[:wait]
        link = link_to "编辑活动", edit_system_activity_path(activity)
      end
    end
    (link || "")
  end

  member_action :check, method: :post do
    activity = Activity.find(params[:id])
    activity.update_attributes(status: Activity.statuses[:access])
    activity.send_checked_mail    
    activity.notice_followers
    redirect_to action: :index
  end

  member_action :reject, method: :post do
    activity = Activity.find(params[:id])
    activity.update_attributes(status: Activity.statuses[:rejected], rejected_reason: params[:reject_reason])
    activity.send_rejected_mail
    redirect_to action: :index
  end
end