#encoding: utf-8
require 'spec_helper'

describe Address, "地址" do

  describe "关联检查" do
    it { should belong_to(:transaction).class_name('OrderTransaction') }
    it { should belong_to(:user) }
    it { should belong_to(:province).class_name('City') }
    it { should belong_to(:city).class_name('City') }
    it { should belong_to(:area).class_name('City') }
    it { should belong_to(:addressable) }
  end

  describe "验证检查" do
    it { should validate_presence_of(:province_id) }
    # it { should validate_superior_of(:city) }
    # it { should validate_superior_of(:area) }
  end

  describe "属性验证" do
    let(:address) { Address.new }
    it { address.should respond_to(:transaction) }
    it { address.should respond_to(:user) }
    it { address.should respond_to(:province) }
    it { address.should respond_to(:city) }
    it { address.should respond_to(:area) }
    it { address.should respond_to(:addressable) }
    it { address.should respond_to(:country) }
    it { address.should respond_to(:road) }
    it { address.should respond_to(:zip_code) }
  end

  let(:user) { FactoryGirl.create(:user) }
  let(:province) { FactoryGirl.create(:province) }
  let(:city) { province.children.create(name: "衡阳", ancestry: province) }
  let(:area) { city.children.create(name: "耒阳", ancestry: city) } 
  let(:address) { FactoryGirl.create(:address,
                                     transaction: nil,
                                     user: user,
                                     province: province,
                                     city: city,
                                     area: area,
                                     addressable: nil) }

  describe "数据验证" do
    it ("默认") { address.should be_valid }
    it "缺少省份" do
        address.province = nil
        address.should_not be_valid
    end
    it "缺少用户" do
        address.user = nil
        address.should be_valid
    end
    it "缺少市" do
        address.city = nil 
        address.should_not be_valid
    end
    it "缺少县" do
        address.area = nil
        address.should_not be_valid
    end
  end

  describe "实例方法" do
    it "location" do
      address.location.should ==
        "#{address.country}#{address.province}#{address.city}#{address.area}#{address.road}"
    end
  end

  describe "验证检查上级" do
    it "正常验证检查  'city' 上级" do
      event = address_obj
      event.should be_a_validate(true)
    end

    it "出错验证检查  'city' 上级" do
      event = address_obj
      event.city_id = '-0' 
      event.should be_a_validate(false)
    end

    it "正常验证检查  'area' 上级" do
      event = address_obj
      event.should be_a_validate(true)
    end

    it "出错验证检查  'area' 上级" do
      event = address_obj
      event.area_id = '-0'
      event.should be_a_validate(false)
    end
  end

  def address_obj
    event = Address.new()
    event.transaction = nil
    event.user_id = user.id
    event.province_id = province.id
    event.city_id = city.id
    event.area_id = area.id
    event.addressable = nil
    event
  end
 
end
 