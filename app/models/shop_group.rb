#encoding: utf-8
# author: huxinghai
# describe: 商店权限组

class ShopGroup < ActiveRecord::Base
  attr_accessible :name

  belongs_to :shop
  has_many :shop_user_groups, :dependent => :destroy
  has_many :group_permissions, :dependent => :destroy, :foreign_key => "group_id"

  validates :name, :presence => true
  validates_presence_of :shop

  validate :valid_name_uniqueness?

  def permissions
    group_permissions.includes(:permission).map{| p | p.permission }
  end

  def users
    shop_user_groups.map{| u | u.user} + [shop.user]
  end

  def self.add(shop_id, opts)
    sg = new(opts)
    sg.shop_id = shop_id
    sg.save
    sg
  end

  def give_permission(permissions)
    permissions.each do | cls_name, abilities |
      abilities.each do | ability |
        permission = Permission.find_by(resource: cls_name, ability: ability)
        if permission
          if find_permission(permission.id).nil?
            group_permissions.create(permission_id: permission.id)
          end
        else
          raise "not define #{cls_name} #{ability} permission!"
        end
      end
    end
  end

  def add_permission(permission_ids)
    Permission.where(:id => permission_ids).each do |p|
      group_permissions.create(permission_id: p.id)
    end
  end

  def remove_permission(group_permission_ids)
    pids = group_permission_ids
    pids = [group_permission_ids] unless group_permission_ids.is_a?(Array)
    group_permissions.where(:permission_id => pids).destroy_all
  end

  def give_all_permission
    ps_ids = permissions.map(&:id)
    ps_ids = [''] if ps_ids.empty?
    Permission.find(:all,
      :conditions => ["id not in (?)", ps_ids]).each do |p|
      group_permissions.create(permission_id: p.id)
    end
  end

  def find_permission(permission_id)
    group_permissions.find_by(:permission_id =>  permission_id)
  end

  def create_user(user_id)
    employee = shop.find_employee(user_id)
    unless employee.nil?
      shop_user_groups.create(:shop_user_id => employee.id)
    end
  end

  def remove_user(user_id)
    employee = shop.find_employee(user_id)
    unless employee.nil?
      sug = shop_user_groups.find_by(:shop_user_id => employee.id)
      sug ? sug.destroy : sug
    end
  end

  def find_user(user_id)
    employee = shop.find_employee(user_id)
    return nil if employee.nil?

    sug = shop_user_groups.find_by(shop_user_id: employee.id)
    return nil if sug.nil?
    sug.user
  end

  def valid_name_uniqueness?
    if ShopGroup.where("name=? and shop_id=? and id<>?", name, shop_id, id).count > 0
      errors.add(:name, "组已经存在！")
    end
  end
end
