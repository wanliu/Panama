#encoding: utf-8
# 物流公司
class LogisticsCompany < ActiveRecord::Base
  attr_accessible :description, :name

  validates :name, :presence => true, :uniqueness => true

  def self.load_data
    data = YAML::load_file("config/data/logistics.yml")["logistics"]
    data.each do |d|
      create(d)
    end
  end
end
