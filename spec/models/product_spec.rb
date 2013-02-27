#encoding: utf-8
require 'spec_helper'

describe Product, "产品模型" do

    let(:shop){ FactoryGirl.create(:shop, :user => FactoryGirl.create(:user)) }
    let(:yifu){ FactoryGirl.create(:yifu, :shop => shop) }
    let(:attachment){ FactoryGirl.create(:attachment) }

    it{ should belong_to(:shop) }
    it{ should belong_to(:default_attachment) }
    it{ should belong_to(:category) }
    it{ should have_and_belong_to_many(:attachments) }
    it{ should have_many(:styles) }

    it{ should validate_presence_of(:category) }
    it{ should validate_presence_of(:shop) }
    it{ should validate_presence_of(:name) }
    it{ should validate_presence_of(:price) }
    it{ should validate_numericality_of(:price) }

    before :each do
        @product = Product.new _attributes
        @product.shop_id = shop.id

        @product.save
    end

    def _attributes
        {
            :name => "iPhone",
            :price => 5,
            :description => "电子产品",
            :summary => "电子",
            :category_id => yifu.id,
            :attachment_ids => [attachment.id],
            :default_attachment_id => attachment.id,
            :shop_id => shop.id
        }
    end


    it "检查属性" do
        product = Product.new
        product.should respond_to(:name)
        product.should respond_to(:description)
        product.should respond_to(:price)
        product.should respond_to(:summary)
        product.should respond_to(:category_id)
        product.should respond_to(:default_attachment_id)
        product.should respond_to(:attachment_ids)
        product.should respond_to(:shop_id)
    end

    it "数据验证" do
        options = _attributes
        product = Product.new options
        product.valid?.should be_true

        product.name = nil
        product.valid?.should be_false

        product.name = "test name"
        product.valid?.should be_true

        product.price = "a"
        product.valid?.should be_false

        product.price = 5
        product.valid?.should be_true

        product.category_id = nil
        product.valid?.should be_false

        product.category_id = yifu.id
        product.valid?.should be_true

        product.save.should be_true
    end


    it "验证关系" do
        @product.valid?.should be_true

        @product.attachments.should be_an_instance_of(Array)
        @product.attachments.select{| a | a.should be_an_instance_of(Attachment) }
        @product.default_attachment.should be_an_instance_of(Attachment)
        @product.shop.should be_an_instance_of(Shop)
        @product.category.should be_an_instance_of(Category)
    end

    describe "method default_photo" do
        it "图型化handler方法" do

            @product.default_photo.should be_an_instance_of(ImageUploader)
        end
    end

    describe "method format_attachment" do
        it "格式化所有附件信息(包括默认附件)" do
            @product.format_attachment.should be_an_instance_of(Array)
            @product.format_attachment.select{|a| a[:default_state] == true }.should have(1).item
            @product.format_attachment.select{|a| a.should have_key(:url) }
        end
    end

  describe "methods that create subs and styles" do
    let(:user)    { FactoryGirl.create(:user) }
    let(:shop)    { FactoryGirl.create(:shop, user: user) }
    let(:category){ FactoryGirl.create(:category, shop: shop) }
    let(:product) { FactoryGirl.create(:product, shop: shop, category: category) }
    let(:colours) { { "0" => {title: "浅粉红", checked: "浅粉红", value: "#FFB6C1" },
                      "1" => {title: "粉红", checked: "粉红", value: "#FFC0CB" } }.symbolize_keys }
    let(:sizes)   { { "0" => {title: "M", value: "M" },
                      "3" => {title: "XL", checked: "XL", value: "XL"}}.symbolize_keys }
    let(:style)   { { "colours" => colours, "sizes" => sizes }.symbolize_keys }
    let(:sub_products) { { "1" => { size: "XL", colour: "浅粉红", price: "55", quantity: "6"},
                           "2" => { size: "XL", colour: "粉红", price: "55", quantity: "2" } }.symbolize_keys }
    let(:params)  { { "style" => style, "sub_products" => sub_products }.symbolize_keys }

    before(:each) do
      product.styles.clear
      product.sub_products.clear
    end

    describe "update_style_subs and create_style_subs" do
      it "invoke create_style and create_subs method" do
        product.should_receive(:create_style).with(style)
        product.should_receive(:create_subs).with(sub_products)

        product.update_style_subs(params)
      end
    end

    describe "create_style" do
      it "add two styel_groups" do
        expect { product.create_style(style) }.to change { product.styles.size }.from(0).to(2)
      end

      it "add four style_items" do
        expect { product.create_style(style) }.to change { StyleItem.all.size }.by(4)
      end
    end

    describe "create_subs" do
      before(:each) { product.create_style(style) }

      it "invoke create_sub 2 times" do
        product.should_receive(:create_sub).exactly(2).times
        product.create_subs(sub_products)
      end

      it "create 2 sub_products" do
        expect { product.create_subs(sub_products) }.to change { product.sub_products.size }.from(0).to(2)
      end

      it "create 4 sytle_pairs" do
        expect { product.create_subs(sub_products) }.to change { StylePair.all.size }.by(4)
      end
    end

    describe "subs_editing" do
      it "return params[:sub_products]" do
        back = product.subs_editing(params)
        back.should eql(sub_products)
      end
    end

    describe "sytles_editing" do
      it "return changed style" do
        expect = style.map { |name, items| { 'name' => name, 'items' => items.values } }
        back = product.sytles_editing(params)
        back.should eql(expect)
      end
    end

  end
end
