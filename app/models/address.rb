class Address
  include Mongoid::Document

  attr_reader :location

  field :country, type: String  # 国家
  field :province, type: String    # 省, 州
  field :city, type: String     # 市
  field :area, type: String   # 县
  field :zip_code, type: String
  field :road, type: String # 地址

  belongs_to :addressable, :polymorphic => true

  def location
    "#{country}#{province}#{city}#{area}#{road}"
  end

end
