#encoding: utf-8
ActiveAdmin.register OrderRefund do
  config.clear_action_items!
  index do
    column :id
    column :order_transaction do |refund|
      refund.try(:order).try(:number)
    end
    column :total
    column :state
    column :buyer do |refund|
      refund.try(:buyer).try(:login)
    end
    column :seller do |refund|
      refund.try(:seller).try(:name)
    end
    column :decription
    column :action_link do |refund|
      link_view = link_to "查看", system_order_refund_path(refund)
      if refund.state == "apply_failure"
        link_agree = link_to "同意", agree_system_order_refund_path(refund), :method => :post
        link_close = link_to "关闭", close_system_order_refund_path(refund), :method => :post
      end
        "#{link_view} #{link_agree} #{link_close}".html_safe
    end
  end

  show do 
    render "show"
  end

  member_action :agree, :method => :post do
    @refund = OrderRefund.find(params[:id])
    event_name = @refund.order.unshipped_state? ? 'unshipped_agree' : 'shipped_agree'
    @refund.fire_events!(event_name)
    @refund.notice_change_buyer(event_name)
    @refund.notice_change_seller(event_name)
    redirect_to system_order_refund_path
  end

  member_action :close, :method => :post do
    @refund = OrderRefund.find(params[:id])
    @refund.fire_events!(:expired)
    redirect_to system_order_refund_path
  end
end