#encoding: utf-8
ActiveAdmin.register OrderTransaction do

  index do
    column :state do |order|
      I18n.t("order_states.buyer.#{order.state}")
    end
    column :total
    column :buyer do |order|
      order.buyer.login
    end
    column :address do |order|
      order.address.try(:location)
    end
    column :person do |order|
      order.transfer_sheet.try(:person)
    end
    column :code do |order|
      order.transfer_sheet.try(:code)
    end
    column :bank do |order|
      order.transfer_sheet.try(:bank)
    end
    column do |order|
      link_to "审核", audit_system_order_transaction_path(order), :method => :post
    end
  end

  controller do
    def index
      index! do |format|
        @order_transactions = OrderTransaction.where(:state => "waiting_audit").page(params[:page])
        format.html
      end
    end
  end

  member_action :audit, :method => :post do
    order = OrderTransaction.find(params[:id])
    order.fire_events!("audit_transfer")
    redirect_to system_order_transaction_path
  end

end