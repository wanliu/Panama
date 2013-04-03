# encoding: utf-8
require 'zlib'

module ApplicationHelper
  include WidgetHelper
  include ContentsHelper

  def l(sym, default)
    t(sym, :default => default)
  end

  def recently_friends
    current_shop.all_friends.order("created_at desc").limit(8)
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

  def industry_title(after)
    after
  end

  def link_to_logout
    link_to l(:sign_out, "退出"), logout_path, :method => :delete
  end

  def link_to_admin
    link_to l(:admin, '管理'), shop_admins_path(@shop.name) if action_controller.respond_to?(:admin?)
  end

  def link_to_account
    link_to current_user.login, person_path(current_user)
  end

  def link_to_notice
    span = content_tag :span, unread_notification_count, :id => "my_notification", :class => "badge badge-warning notification"
    link_to span, person_notifications_path(current_user.login)
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

  def icon(name)
    content_tag :i, nil, :class => "icon-#{name}"
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
    output = "".html_safe
    array.shift
    last = array.pop
    output = link_to '#CategoryModal', 'data-remote' => category_page_shop_admins_products_path, 'data-toggle' => 'modal' do
      content_tag :ul, :class => [:breadcrumb, :btn, name] do
        array.each do |e|
          output << content_tag(:li) do
            link_to(e.name, '#') +
            content_tag(:span, '|', :class => "divider")
          end
        end

        output << content_tag(:li) do
          last.name
        end
      end
    end
  end
end
