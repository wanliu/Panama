#encoding: utf-8
class Admins::Shops::SectionController < Admins::BaseController
  include Apotomo::Rails::ControllerMethods

  before_filter :current_shop
  helper_method :current_section, :current_shop


  # section :dashboard, :top
  section :shop_info, :shop
  section :bill_detail,  :shop

  section :pending, :transactions
  section :direct_transactions, :transactions
  section :complete, :transactions
  # section :transport, :transportation
  # section :products, :products
  section :shop_products, :products
  section :product_comments, :products
  # section :categories, :products
  # section :complaint, :service
  section :contents, :design
  section :menu, :design
  section :templates, :design
  section :employees, :admins
  # section :communities, :admins
  section :order_refunds, :transactions
  section :banks, :admins

  cattr_accessor :ajaxify_pages_names
  @@ajaxify_pages_names = []

  def current_ability
    @current_ability ||= ShopAbility.new(current_user, current_shop)
  end

  def self.ajaxify_pages(*args)
    ajaxify_pages_names.concat args
  end

  def render(*args, &block)
    if ajaxify_pages_names.include?(action_name.to_sym) && params[:ajaxify]
      options = args.extract_options!
      options[:layout] = false
      args.push options
    end
    super *args
  end

  def current_section
    self.controller_name
  end
end