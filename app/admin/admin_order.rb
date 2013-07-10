#encoding: utf-8
ActiveAdmin.register OrderTransaction do

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
      if order.waiting_audit_state?
        content_tag :div do
          link = link_to "通过", audit_system_order_transaction_path(order), :method => :post
          link1 = link_to "未通过", audit_failure_system_order_transaction_path(order), :method => :post
          "#{link}  #{link1}".html_safe
        end
      end
    end
  end

  controller do
    def index
      index! do |format|
        @order_transactions = @order_transactions.where(
          :state => "waiting_audit").page(params[:page]) if params[:q].nil?
        format.html
      end
    end
  end

  member_action :audit, :method => :post do
    order = OrderTransaction.find(params[:id])
    order.fire_events!("audit_transfer")
    redirect_to system_order_transaction_path
  end

  member_action :audit_failure, :method => :post do
    order = OrderTransaction.find(params[:id])
    order.fire_events!("audit_failure")
    redirect_to system_order_transaction_path
  end
end