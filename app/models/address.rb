class Address
  include Mongoid::Document

  attr_reader :location

  field :country, type: String  # 国家
  field :zip_code, type: String
  field :road, type: String # 地址

  has_one :province, :inverse_of => :address , class_name: "City"  # 省, 州
  has_one :city, :inverse_of => :address , class_name: "City"     # 市
  has_one :area, :inverse_of => :address , class_name: "City"   # 县
  belongs_to :addressable, :polymorphic => true

  def location
    "#{country}#{province}#{city}#{area}#{road}"
  end

end
