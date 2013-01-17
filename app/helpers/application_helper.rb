# encoding: utf-8
require 'zlib'

module ApplicationHelper
  include WidgetHelper

  def l(sym, default)
    t(sym, :default => default)
  end

  def current_user
    return nil unless session[:user_id]
    @current_user ||= User.where(:uid => session[:user_id]['uid']).first
  end

  def accounts_provider_url
    Rails.application.config.sso_provider_url
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
    link_to l(:admin, '管理'), action_controller.admin_path if action_controller.respond_to?(:admin?)
  end

  def link_to_account
    link_to current_user.login, '#'
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

  def caret(position = :down)
    content_tag :span, nil, :class => [:caret, position]
  end

  def options_dom_id(object, options = {})
    as = options[:as]
    action, method = object.respond_to?(:persisted?) && object.persisted? ? [:edit, :put] : [:new, :post]
    as ? "#{action}_#{as}" : [options[:namespace], dom_id(object, action)].compact.join("_").presence
  end

  def build_menu(root)
    output = ActiveSupport::SafeBuffer.new
    if root.children && root.children.size && root.children.size > 0
      content_tag(:ul, :class => "dropdown-menu") do 
        root.children.map do |node|
          if node.children && node.children.size > 0
            output.concat(content_tag(:li, :class => 'dropdown-submenu') do 
              link_to(node.name.humanize, node, :html => {tabindex: -1}) + 
              build_menu(node)
            end)
          else
            output.concat(content_tag(:li) do 
              link_to node.name.humanize, node
            end)
          end
        end
        output
      end
    end
  end
end
