class Admins::Shops::SectionController < Admins::BaseController
  include Apotomo::Rails::ControllerMethods

  before_filter :current_shop, :only => [:new, :index, :edit]
  helper_method :current_section, :current_shop

  section :dashboard, :top
  section :pending, :transactions
  section :complete, :transactions
  section :transport, :transportation
  section :products, :products
  section :categories, :products
  section :complaint, :service
  section :contents, :design
  section :menu, :design
  section :templates, :design
  section :employees, :admins

  cattr_accessor :ajaxify_pages_names
  @@ajaxify_pages_names = []

  def current_shop
    @current_shop = Shop.find_by(:name => params[:shop_id])
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
    super
  end

  def current_section
    self.controller_name
  end
end