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

  member_action :check, method: :post do
    activity = Activity.find(params[:id])
    activity.update_attributes(status: Activity.statuses[:access])
    activity.send_checked_mail

    redirect_to action: :index
  end

  member_action :reject, method: :post do
    activity = Activity.find(params[:id])
    activity.update_attributes(status: Activity.statuses[:rejected], rejected_reason: params[:reject_reason])
    activity.send_rejected_mail

    redirect_to action: :index
  end
end