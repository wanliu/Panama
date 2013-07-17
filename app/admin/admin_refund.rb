#encoding: utf-8
ActiveAdmin.register OrderRefund do

  index do
    column :id
    column :order_transaction do |refund|
      refund.order.number
    end
    column :total
    column :state
    column :buyer do |refund|
      refund.buyer.login
    end
    column :seller do |refund|
      refund.seller.name
    end
    column :decription
    column :action_link do |refund|
      if refund.state == "apply_failure"
        link_to "同意", agree_system_order_refund_path(refund), :method => :post
      end
    end
  end

  member_action :agree, :method => :post do
    @refund = OrderRefund.find(params[:id])
    event_name = @refund.order.unshipped_state? ? 'unshipped_agree' : 'shipped_agree'
    @refund.fire_events!(event_name)
    redirect_to system_order_refund_path
  end
end