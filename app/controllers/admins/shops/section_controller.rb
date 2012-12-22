class Admins::Shops::SectionController < Admins::BaseController
  before_filter :current_shop, :only => [:new, :index, :edit]

  section :dashboard
  section :contents
  section :menu
  section :categories
  section :templates

  cattr_accessor :ajaxify_pages_names
  @@ajaxify_pages_names = []

  def current_shop
    @current_shop = Shop.find(params[:shop_id])
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
end