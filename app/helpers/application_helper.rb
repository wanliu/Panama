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

  def token
    current_user.im_token
  end

  def default_img_url(version_name)
    ImageUploader.new.url(version_name)
  end

  def my_cart
    current_user.cart
  end

  def accounts_provider_url
    OmniAuth::Wanliu.config["provider_url"]
  end

  def faye_server_uri
    Settings.defaults["faye_server"]
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

  def title
    @title ||= "#{t(controller_name, :default => '万流平台')} #{t(action_name, :default => action_name)}"
  end

  def industry_title(after)
    after
  end

  def link_to_logout
    link_to logout_path, :method => :delete do
      icon(:signout) + ' ' + t(:logout)
    end
  end

  def link_to_admin
    if action_controller.respond_to?(:admin?)
      link_to shop_admins_path(@shop.name), 'data-toggle' => "popover", 'data-placement' => "bottom", 'data-original-title' => "Settings" do
        icon :cog
      end
    end
  end

  def link_to_account
    link_to person_path(current_user) do
      icon(:user) + ' ' + t(:account)
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

    content_tag :i, nil, :class => names.map {|n| "icon-#{n}" }
  end

  def caret(position = :down, *styles)
    content_tag :span, nil, :class => [:caret, position, *styles]
  end

  def options_dom_id(object, options = {})
    as = options[:as]
    action, method = object.respond_to?(:persisted?) && object.persisted? ? [:edit, :put] : [:new, :post]
    as ? "#{action}_#{as}" : [options[:namespace], dom_id(object, action)].compact.join("_").presence
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

  def breadcrumb_button(name, array)
    # debugger
    output = "".html_safe
    array.shift
    # ISSUE: 临时方案, 需要修改 rails.view.js 的 提交 bug
    last = array.pop || OpenStruct.new(:name => 'Noselected')
    # BUG: 'data-remote' => category_page_shop_admins_products_path, 设置这个参数,会触发
    #   jquery_ujs 不正常的功能
    output = link_to '#',  'data-toggle' => 'modal' do
      content_tag :ul, :class => [:breadcrumb, :btn, name] do
        array.each do |e|
          output << content_tag(:li) do
            link_to(e.name, '#') +
            # e.name +
            content_tag(:span, '|', :class => "divider")
          end
        end

        output << content_tag(:li) do
          last.name
        end
      end
    end
  end

  def get_delivery_type
    @delivery_types = DeliveryType.all
  end

  def dispose_options(product)
    attachments = product.fetch(:attachment_ids, {})
    {:attachment_ids => attachments.map{|k, v| v} }
  end

end
