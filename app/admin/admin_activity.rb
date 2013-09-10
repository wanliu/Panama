#encoding: utf-8

ActiveAdmin.register Activity do
  form :partial => "form"

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

    column do |c|
      link_1 = link_to "查看", system_activity_path(c), :class =>"member_link"
      if c.status == Activity.statuses[:rejected]
        link_2 = link_to "编辑", edit_system_activity_path(c), :class =>"member_link"
        link_3 = link_to "删除", system_activity_path(c), :method => :delete, :confirm => "Are you sure?", :class =>"member_link"
      end
      link_1 + (link_2 || "") + (link_3 || "")
    end
  end

  show do
    render "check_info"
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