#encoding: utf-8
# describe: 权限
class Permission < ActiveRecord::Base
  attr_accessible :ability, :resource

  validates :ability, :presence => true
  validates :resource, :presence => true

  has_many :group_permissions, dependent: :destroy

  def self.define(resource, abilities)
    unless abilities.is_a?(Array)
      abilities = [abilities]
    end
    abilities.each do |ability|
      if find_by(resource: resource, ability: ability).nil?
        create(resource: resource, ability: ability)
      end
    end
  end
end
