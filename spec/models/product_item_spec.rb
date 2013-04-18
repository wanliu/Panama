#encoding: utf-8
require 'spec_helper'

describe ProductItem, "购物车 商品 " do

  def prod_item
		{
			:amount => 11,
			:price => 12345,
			:total =>  123456,
			:product_id => 1,
			:cart_id => 1
		}
	end

  describe "关联检查" do
    it { should belong_to(:cart) }
    # 废弃 (Deprecated), :sub_product
    # it { should belong_to(:sub_product) }
    it { should belong_to(:transaction).class_name("OrderTransaction") }
  end

  describe "属性验证" do
    let(:product_item) { ProductItem.new }
    it { product_item.should respond_to(:amount) }
    it { product_item.should respond_to(:price) }
    # 废弃 (Deprecated), :sub_product
    # it { product_item.should respond_to(:sub_product) }
    it { product_item.should respond_to(:title) }
    it { product_item.should respond_to(:total) }
    it { product_item.should respond_to(:transaction) }
    it { product_item.should respond_to(:cart_id) }
  end

  describe "实例方法" do
    describe "product" do
      let(:user) { FactoryGirl.create(:user)}
      let(:shop) { FactoryGirl.create(:shop, user: user) }
      let(:category)    { FactoryGirl.create(:category) }
      let(:shops_category) {
                          FactoryGirl.create(:shops_category, shop: shop) }
      let(:product)     { FactoryGirl.create(:product,
                                             category: category,
                                             shops_category: shops_category,
                                             shop: shop) }
      # 废弃 (Deprecated), :sub_product
      # let(:sub_product) { FactoryGirl.create(:sub_product, product: product) }

      it "返回product" do
        item = ProductItem.new(product_id: product.id)
        item.product.should == product
      end
    end
  end

  describe "模型装饰" do
  	it "模型装饰  price " do
    	pr = ProductItem.create! prod_item
    	pr_de = pr.decorate
    	pr_de.source.price.should eq(pr_de.price.delete(', ¥$').to_f)
    end

    it "模型装饰  total " do
    	pr = ProductItem.create! prod_item
    	pr_de = pr.decorate
    	pr_de.source.total.should eq(pr_de.total.delete(', ¥$').to_f)
    end
  end

  describe "动态属性" do

    let(:user) { FactoryGirl.create :user }
    let(:shop) { FactoryGirl.create :shop, :user => user }
    # let(:)

    let(:order1) { FactoryGirl.create(:transaction,
                                      :buyer  => user,
                                      :seller => shop ) }

    let(:cart)         { user.cart }
    let(:product_item) { FactoryGirl.create(:product_item,
                                            :cart => cart,
                                            :product => Product.first,
                                            :transaction => order1) }

    let(:colour)       { Property.find_by_name("colour") }
    let(:sizes)       { Property.find_by_name("sizes") }


    it "添加属性" do
      product_item.properties << Property.first
      product_item.delegate_property_setup
      product_item.weight = 13
      product_item.save
      ProductItem.last.weight.should eql(13)
    end

    it "添加属性 sizes" do
      product_item.properties << Property.find_by_name("sizes")
      product_item.delegate_property_setup
      product_item.sizes = "S"
      product_item.save
      ProductItem.last.sizes.should == "S"
    end

    it "扩展的 create" do
      apple = Product.first
      apple.properties << sizes
      apple.properties << colour
      apple.price_options.create(:property => sizes)
      apple.price_options.create(:property => colour)
      item = ProductItem.create(:product => apple, :options => { :sizes => "L", :colour => "red" })
      item.sizes.should == "L"
      item.colour.should == "red"
    end

  end

  describe "内存关联" do
    let(:pi) { ProductItem.new(:product_id => Product.first) }

    it "添加一个关联" do
      expect {
        pi.properties << Property.first
      }.to change{ pi.properties.size }.by(1)
    end

    it "添加多个关联" do

      size = Property.all.size
      expect {
        pi.properties << Property.all
      }.to change { pi.properties.size }.by(size)
    end

    it "添加一个关联并保存" do
      expect {
        pi.properties << Property.first
      }.to change{ pi.properties.size }.by(1)

      pi.save.should be_true

      ProductItem.last.properties.should eq([Property.first])
    end

    it "添加多个关联并保存" do
      size = Property.all.size

      expect {
        pi.properties << Property.all
      }.to change{ pi.properties.size }.by(size)

      pi.save.should be_true

      ProductItem.last.properties.should eq(Property.all)
    end

    it "添加多个关联, 并不增加记录" do
      size = Property.all.size

      expect {
        pi.properties << Property.all
      }.to change{ ProductItem.count }.by(0)

    end

    describe  "触发 callbacks" do

      it "添加两关联, 并触发 callbacks" do
        # pi.class.after_add_for_properties << :add_property
        pi.should_receive(:add_property).twice
        pi.properties << Property.all[0..1]
      end

    end
  end
end
