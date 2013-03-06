class Address < ActiveRecord::Base
  include Custom::Validators

  attr_accessible :country, :road, :zip_code

  belongs_to :transaction,
             class_name: 'OrderTransaction'
  belongs_to :user
  belongs_to :province, :inverse_of => :address , class_name: "City"  # 省, 州
  belongs_to :city, :inverse_of => :address , class_name: "City"     # 市
  belongs_to :area, :inverse_of => :address , class_name: "City"   # 县
  belongs_to :addressable, :polymorphic => true

  def location
    "#{country}#{province}#{city}#{area}#{road}"
  end

  validates :province_id, {:presence => true }
  validates :city, :superior => {:target => :province, :att => :city_id }
  validates :area, :superior => {:target => :city , :att => :area_id }

end
