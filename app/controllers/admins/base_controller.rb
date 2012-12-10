class Admins::BaseController < ApplicationController
  include Apotomo::Rails::ControllerMethods

  layout "admins"

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

end

Admins::BaseController.sections = []