#encoding: utf-8
ActiveAdmin.register OrderTransaction do

  scope :等待审核, default: true do
    OrderTransaction.where("state = 'waiting_audit'")
  end

  scope :被驳回 do
    OrderTransaction.where("state = 'waiting_audit_failure'")
  end

  scope :已审核通过 do
    OrderTransaction.joins(:pay_manner).joins(:state_details).where("transaction_state_details.state='waiting_delivery' and pay_manners.code = 'bank_transfer'")
  end

  index do
    column :state do |order|
      I18n.t("order_states.buyer.#{order.state}")
    end
    column :pay_manner do |order|
      order.pay_manner.name
    end
    column :total
    column :buyer do |order|
      order.buyer.login
    end
    column :address do |order|
      order.address.try(:location)
    end
    column :transfer_person do |order|
      order.transfer_sheet.try(:person)
    end
    column :transfer_code do |order|
      order.transfer_sheet.try(:code)
    end
    column :transfer_bank do |order|
      order.transfer_sheet.try(:bank)
    end
    column :action_link do |order|
      content_tag :div do
        view_link = link_to "查看", system_order_transaction_path(order), :method => :get
        view_link.html_safe
      end
    end
  end

  show do
    render "check_info"
  end

  # controller do
  #   def index
  #     index! do |format|
  #       @order_transactions = @order_transactions.where(
  #         :state => "waiting_audit").page(params[:page]) if params[:q].nil?
  #       format.html
  #     end
  #   end
  # end

  member_action :audit, :method => :post do
    order = OrderTransaction.find(params[:id])
    order.fire_events!("audit_transfer")
    order.notice_change_buyer("audit_transfer")
    order.notice_change_seller("audit_transfer")
    redirect_to system_order_transaction_path
  end

  member_action :audit_failure, :method => :post do
    order = OrderTransaction.find(params[:id])
    order.fire_events!("audit_failure")
    order.notice_change_buyer("audit_failure")
    order.notice_change_seller("audit_failure")
    redirect_to system_order_transaction_path
  end
end