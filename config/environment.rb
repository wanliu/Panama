# Load the rails application
require File.expand_path('../application', __FILE__)
require 'wanliu_id'
# Initialize the rails application

require 'active_merchant'
require 'active_merchant/billing/integrations/action_view_helper'

ActiveMerchant::Billing::Integrations::Alipay::Helper::KEY = 'asdf'
ActionView::Base.send(:include, ActiveMerchant::Billing::Integrations::ActionViewHelper)
Panama::Application.initialize!
