class Admins::BaseController < ApplicationController


  layout "admins"

  before_filter :login_required

  helper_method :current_admin_path

  cattr_accessor :sections

  def section
    name = params[:section_name]
    # debugger
    sect = sections.find {|sect| sect[:name] == name.to_sym }
    raise "invalid section name: #{name}" unless sect
    self.instance_exec &sect[:block] if sect[:block]
    render name
  end

  def sections
    self.class.sections
  end

  protected

  class << self
    def section(name, *args, &block)
      sections << {:name => name, :block => block}
    end
  end

  def current_admin_path
    "/shops/#{params[:shop_id]}/admins/"
  end
end

Admins::BaseController.sections = []