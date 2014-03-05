# encoding: utf-8
require 'zlib'

module ApplicationHelper
  include WidgetHelper
  include ContentsHelper

  def l(sym, default)
    t(sym, :default => default)
  end

  def shop_recently_friends
    ids = current_shop.circle_all_friends.order("created_at desc").limit(8)
    .map{|f| f.user_id}
    User.where(id: ids)
  end

  def user_recently_friends
    ids = current_user.circle_all_friends.order("created_at desc").limit(8)
    .map{|f| f.user_id}
    User.where(id: ids)
  end

  def community_active(name)
    content_for(:active_community){ name.to_s }
  end

  def circle_active(name)
    content_for(:active_circle){ name.to_s }
  end

  def current_user
    @current_user ||= User.where(:uid => session[:user_id]).first if session[:user_id]
  end

  def current_admin
    @current_admin ||= AdminUser.where(:uid => session[:admin_id]).first if session[:admin_id]
  end

  def side_nav_for(name)
    content_for(:side_nav) do
      name.to_s
    end
  end

  def recharge_payment_url
    if payment_mode?
      test_payment_person_recharges_path(current_user)
    else
      payment_person_recharges_path(current_user)
    end
  end

  def payment_mode?
    Settings.pay_mode == "test"
  end

  def product_join_state(products, shop_id)
    product_ids = []
    if shop_id.present?
      product_ids = Shop.find(shop_id).products.pluck("product_id")
    end
    products.map do |p|
      product = p.as_json
      product[:join_state] = product_ids.include?(p.id.to_i)
      product
    end
  end

  def payment_order_path(people, record)
    if payment_mode?
      test_payment_person_transaction_path(people, record)
    else
      kuaiqian_payment_person_transaction_path(people, record)
    end
  end

  def current_shop
    @current_shop = Shop.find_by(:name => params[:shop_id]) unless params[:shop_id].blank?
    if !@current_shop.blank? && @current_shop.user != current_user &&
      @current_shop.find_employee(current_user.id).nil?
      redirect_to shop_path(params[:shop_id])
      return
    end
    @current_shop
  end

  def token
    current_user.im_token
  end

  def default_img_url(version_name)
    ImageUploader.new.url(version_name)
  end

  def my_cart
    current_user.try(:cart)
  end

  def my_likes
    current_user.liked_activities
  end

  def accounts_provider_url
    OmniAuth::Wanliu.config["provider_url"]
  end

  # def faye_server_uri
  #   Settings.faye_server
  # end

  def realtime_uri
    Settings.caramal_server
  end

  def action_controller
    if controller.is_a?(ActionController::Base)
      controller
    elsif controller.respond_to?(:action_controller)
      controller.action_controller
    else
      nil
    end
  end

  def site_name
    Settings.site_name "万流平台"
  end

  def default_title
    "#{t(controller_name)} #{t(action_name, :default => action_name)} - #{site_name}"
  end

  def controller_title
    "#{controller.title} - #{site_name}" if controller.respond_to?(:title)
  end

  def display_title
    @title ||= controller_title or default_title
  end

  def industry_title(after)
    after
  end

  def link_to_logout
    link_to logout_path, :method => :delete do
      icon(:signout) + ' 注销登录'
    end
  end

  def link_to_community
    link_to person_communities_path(current_user)  do
      icon(:group) + " 我的商圈"
    end
  end

  def link_to_admin
    if action_controller.respond_to?(:admin?)
      link_to shop_admins_path(@shop.name), 'data-toggle' => "popover", 'data-placement' => "bottom", 'data-original-title' => "Settings", :title => "商店管理" do
        icon :cog
      end
    end
  end

  def link_to_account
    link_to person_notifications_path(current_user) do
      icon(:user) + ' 我的账户'
    end
  end

  def account_info
    image_tag(current_user.icon, :class => "user_icon") + current_user.login
  end

  def link_to_notice
    # span = content_tag :span, unread_notification_count, :id => "my_notification", :class => "badge badge-warning notification"
    # link_to span, person_notifications_path(current_user.login)
    link_to person_notifications_path(current_user.login),
            :title => t(:unread_notification, count: unread_notification_count),
            :class => "dropdown-toggle",
            'data-taggle' => "dropdown" do
        icon(:group) + content_tag(:span, unread_notification_count, :class => 'count')
    end
  end

  def link_to_mycart(title, *args, &block)
    if block_given?
      url, selector, options = title, *args
      options ||= {}
      options.merge!({
        'add-to-cart'   => selector,
        'add-to-action' => url
      })
      link_to url, options, &block
    else
      options ||= {}
      url, selector, options = *args
      options.merge!({
        'add-to-cart'   => selector,
        'add-to-action' => url
      })
      link_to title, url, options
    end
  end

  def unread_notification_count
    Notification.unreads.where(:user_id => current_user.id).count
  end

  def find_resource_by(resource)
    Permission.where(resource: resource)
  end

  def search_box(name, value = nil, options = { size: 40})
    text_field_tag name, value, options
    button_tag l(:search, '搜索')
  end

  @@javascripts_codes = {}

  def javascripts_codes
    output = ActiveSupport::SafeBuffer.new
    @@javascripts_codes.each do |key, code|
      output.safe_concat code
    end
    output
  end

  def register_javascript(name, options = {}, &block)
    code = capture { yield } if block_given?
    if request.xhr?
      code
    else
      unless options[:only] == :ajax
        @@javascripts_codes[name] = code
      end
      nil
    end
  end

  def icon(*names)
    content_tag :span, nil, :class => names.map {|n| "icon-#{n}" }
  end

  def caret(position = :down, *styles)
    content_tag :span, nil, :class => [:caret, position, *styles]
  end

  def options_dom_id(object, options = {})
    as = options[:as]
    action, method = object.respond_to?(:persisted?) && object.persisted? ? [:edit, :put] : [:new, :post]
    as ? "#{action}_#{as}" : [options[:namespace], dom_id(object, action)].compact.join("_").presence
  end

  def build_menu3(root, nodes_ids , element_id = nil, options = { :ul_class => 'tree-body collapse',
                                                                  :li_class => 'tree-group',
                                                                  :first_class => 'tree-nav',
                                                                  :toggle => 'slide' })
    output = ActiveSupport::SafeBuffer.new
    if root.children && !contain_children(root, nodes_ids).blank?
      content_tag(:ul, :class => options[:first_class] || options[:ul_class], :id => element_id || dom_id(root)) do 
        options.delete(:first_class)
        contain_children(root, nodes_ids).map do |node|
          if node.children && node.children.size > 0
            output.concat(content_tag(:li, :class => options[:li_class]) do 
              link_to("##{dom_id(node)}", :html => {tabindex: -1}, 'data-id' => node.id, 'data-name' => node.name, 'data-toggle' => options[:toggle]) {
                icon('caret-right') + " " + node.name
                } +
              build_menu3(node, nodes_ids, nil, options)
            end)
          else
            output.concat(content_tag(:li) do
              link_to node.name, node, 'data-id' => node.id, 'data-name' => node.name , 'class' => 'leaf_node', 'onclick' => 'javascript:void(0);return false;'
            end)
          end
        end
        output
      end
    end
  end

  def contain_children(root, children_ids )
    categories = root.children.pluck("id") & children_ids.flatten
    Category.where(:id => categories)
  end

  def build_menu(root, element_id = nil)
    output = ActiveSupport::SafeBuffer.new
    if root.children && root.children.size && root.children.size > 0
      content_tag(:ul, :class => "dropdown-menu", :id => element_id) do
        root.children.map do |node|
          if node.children && node.children.size > 0
            output.concat(content_tag(:li, :class => 'dropdown-submenu') do
              link_to(node.name, node, :html => {tabindex: -1}, 'data-id' => node.id, 'data-name' => node.name) +
              build_menu(node)
            end)
          else
            output.concat(content_tag(:li) do
              link_to node.name, node, 'data-id' => node.id, 'data-name' => node.name
            end)
          end
        end
        output
      end
    end
  end

  def build_menu2(root, element_id = nil, options = { :ul_class => 'tree-body collapse',
                                                      :li_class => 'tree-group',
                                                      :first_class => 'tree-nav',
                                                      :toggle => 'slide' })
    output = ActiveSupport::SafeBuffer.new
    if root.children && root.children.size && root.children.size > 0
      content_tag(:ul, :class => options[:first_class] || options[:ul_class], :id => element_id || dom_id(root)) do
        options.delete(:first_class)
        root.children.map do |node|
          if node.children && node.children.size > 0
            output.concat(content_tag(:li, :class => options[:li_class]) do
              link_to("##{dom_id(node)}", :html => {tabindex: -1}, 'data-id' => node.id, 'data-name' => node.name, 'data-toggle' => options[:toggle]) {
                icon('caret-right') + " " + node.name
                } +
              build_menu2(node, nil, options)
            end)
          else
            output.concat(content_tag(:li) do
              link_to node.name, node, 'data-id' => node.id, 'data-name' => node.name, 'class' => 'leaf_node', 'onclick' => 'javascript:void(0);return false;'
            end)
          end
        end
        output
      end
    end
  end

  def breadcrumb_button(name, array, icon_name = nil, &block)
    output = "".html_safe
    array.shift if array.length > 1
    # ISSUE: 临时方案, 需要修改 rails.view.js 的 提交 bug
    last = array.pop || OpenStruct.new(:name => '未选择')
    # BUG: 'data-remote' => category_page_shop_admins_products_path, 设置这个参数,会触发
    #   jquery_ujs 不正常的功能
    #output = link_to '#',  'data-toggle' => 'modal' do
    content_tag :ul, :class => [:breadcrumb, name] do
      if icon_name.present?
        output << content_tag(:li, :class => 'icon'){ link_to icon(icon_name), "/" }
      end
      array.each do |e|
        output << content_tag(:li) do
          url = yield e if block_given?
          url + content_tag(:span, '>', :class => "divider")
        end
      end

      output << content_tag(:li, :class => "active") do
        yield last if block_given?
      end
    end
    #end
  end
  
  def get_delivery_type
    @delivery_types = DeliveryType.all
  end

  def dispose_options(product)
    attachments = product.fetch(:attachment_ids, {})
    {:attachment_ids => attachments.map{|k, v| v} }
  end

  def upload_tip
    '<small>
      请选择小于1MB的jpg/png<br />gif格式的图片<br />
    </small>'.html_safe
  end

  def city_by_ip(client_ip)
    client_ip = "124.228.76.190" unless Rails.env.production?
    address = IPSearch.ip_query(client_ip)
    if address.blank? || (address["status"] == 1)
      City.find_by_name("衡阳市")
    else
      address_detail = address["content"]["address_detail"]
      province_id = City.where(name: address_detail["province"]).pluck("id")[0]
      City.find(province_id).children.find_by_name(address_detail["city"])
    end
  end

  def follow_action(follow)
    method, owner = if follow.is_a?(User)
      ['is_follow_user?', follow]
    else
      ['is_follow_shop?', follow.user]
    end

    return if current_user == owner
    class_name, title = if current_user.send(method, follow)
      [:unfollow, "取消关注"]
    else
      [:follow, "+关注"]
    end
    label_class = class_name == :follow ? 'success' : 'important'
    label_tag class_name, title, :class => "label label-#{label_class} #{class_name}"
  end

  def city_ids(city_id)
    @region = RegionCity.location_region(city_id)
    unless @region.blank?
      @region.region_cities_ids()
    else
      city_id
    end
  end

  def render_base_template(template, options = {})
    render :partial => "#{base_template_path}/#{template}", locals: options
  end

  def has_right_to_answer_ask_buy?(ask_buy)
    !current_user.belongs_shop.nil?  && ask_buy.open && current_user.belongs_shop.actived && ask_buy.user_id != current_user.id 
  end
end
