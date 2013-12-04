module Admins::Shops::TransactionsHelper

  def render_base_template(template, options = {})
    render :partial => "admins/shops/transactions/base/#{template}", :locals => options
  end
end
