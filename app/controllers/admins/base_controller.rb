class Admins::BaseController < ApplicationController

  layout "admins"

  before_filter :login_and_service_required

  helper_method :current_admin_path, :sections

  def section
    name = params[:section_name]
    sect = sections.find {|sect| sect[:name] == name.to_sym }
    raise "invalid section name: #{name}" unless sect
    self.instance_exec &sect[:block] if sect[:block]
    render name
  end

  def sections(category = nil)
    if category == :all || category.nil?
      self.class.sections
    elsif category.is_a?(Array)
      self.class.sections.select { |s| category.include?(s[:category]) }
    else
      self.class.sections.select { |s| category == s[:category] }
    end
  end

  protected

  class << self
    @@sections = []

    def section(name, category, *args, &block)
      @@sections << {:name => name, :category => category, :block => block}
    end

    def sections
      @@sections ||= []
    end
  end

  def current_admin_path
    "/shops/#{params[:shop_id]}/admins/"
  end
end
