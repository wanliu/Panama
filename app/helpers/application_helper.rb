# encoding: utf-8

module ApplicationHelper

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

  def industry_title(after)
    after
  end

  def link_to_logout
    link_to l(:sign_out, "退出"), logout_path, :method => :delete
  end

  def link_to_account
    link_to current_user.login, '#'
  end

  def search_box(name, value = nil, options = { size: 40})
    text_field_tag name, value, options
    button_tag l(:search, '搜索')
  end

end
