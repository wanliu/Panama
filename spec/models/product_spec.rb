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

        product.shop_id.should be_nil
        product.valid?.should be_false

        product.shop_id = shop.id
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
end
