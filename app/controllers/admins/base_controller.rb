class Admins::BaseController < ApplicationController
  layout "admins"

  cattr_accessor :sections

  def sections
    self.class.sections
  end

  protected

  class << self
    def section(name, *args)
      sections << {:name => name}
    end
  end

end

Admins::BaseController.sections = []