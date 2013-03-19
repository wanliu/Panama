#encoding: utf-8
# author: huxinghai
# describe: 商店权限组

class ShopGroup < ActiveRecord::Base
  attr_accessible :name

  belongs_to :shop
  has_many :shop_user_groups

  validates :name, :presence => true
  validates_presence_of :shop

  def users
    shop_user_groups.map{| u | u.user}
  end

  def self.add(shop_id, opts)
    sg = ShopGroup.new(opts)
    sg.shop_id = shop_id
    sg.save
    sg
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
end
