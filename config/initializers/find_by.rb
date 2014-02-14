require 'active_record'

class ActiveRecord::Base

  def self.find_by(conditions)
    where(conditions).first
  end
end