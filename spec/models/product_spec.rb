#encoding: utf-8
require 'spec_helper'

describe Product, "商品模型" do

    let(:shop){ FactoryGirl.create(:shop, :user => FactoryGirl.create(:user)) }
    let(:category) { FactoryGirl.create(:category) }
    let(:yifu){ FactoryGirl.create(:yifu, :shop => shop) }
    let(:attachment){ FactoryGirl.create(:attachment) }

    it{ should belong_to(:shop) }
    it{ should belong_to(:default_attachment) }
    it{ should belong_to(:category) }
    it{ should have_and_belong_to_many(:attachments) }

    # it{ should validate_presence_of(:shops_category) }
    # it{ should validate_presence_of(:shop) }
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
            :description => "电子商品",
            :summary => "电子",
            :category_id => category.id,
            :shops_category_id => yifu.id,
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

    it "验证关系" do
        @product.valid?.should be_true

        @product.attachments.should be_an_instance_of(Array)
        @product.attachments.select{| a | a.should be_an_instance_of(Attachment) }
        @product.default_attachment.should be_an_instance_of(Attachment)
        @product.shop.should be_an_instance_of(Shop)
        @product.category.should be_an_instance_of(Category)
    end

    describe "模型装饰" do
        it "模型装饰  price " do
            pr_de = @product.decorate
            pr_de.source.price.should eq(pr_de.price.delete(', ¥$').to_f)
        end
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
    let(:shops_category){
                    FactoryGirl.create(:shops_category, shop: shop) }
    let(:category){ FactoryGirl.create(:category) }
    let(:product) { FactoryGirl.create(:product, shop: shop,
                                       category: category,
                                       shops_category: shops_category) }
    let(:colours) { { "0" => {title: "浅粉红", checked: "浅粉红", value: "#FFB6C1" },
                      "1" => {title: "粉红", checked: "粉红", value: "#FFC0CB" } }.symbolize_keys }
    let(:sizes)   { { "0" => {title: "M", value: "M" },
                      "3" => {title: "XL", checked: "XL", value: "XL"}}.symbolize_keys }
    let(:style)   { { "colours" => colours, "sizes" => sizes }.symbolize_keys }
    let(:sub_products) { { "1" => { size: "XL", colour: "浅粉红", price: "55", quantity: "6"},
                           "2" => { size: "XL", colour: "粉红", price: "55", quantity: "2" } }.symbolize_keys }
    let(:params)  { { "style" => style, "sub_products" => sub_products }.symbolize_keys }


    describe "old style", :if => false do

        describe "update_style_subs and create_style_subs" do
          it "invoke create_style and create_subs method" do
            product.should_receive(:create_style).with(style)
            product.should_receive(:create_subs).with(sub_products)

            product.update_style_subs(params)
          end
        end

        describe "create_style" do
          # FIXED: 替换成新的 属性
          # it "add two styel_groups" do
          #   expect { product.create_style(style) }.to change { product.styles.size }.from(0).to(2)
          # end

          # it "add four style_items" do
          #   expect { product.create_style(style) }.to change { StyleItem.all.size }.by(4)
          # end
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


    # 为商品增加一些附加属性,这些属性可以通过系统配置来进行管理, 同时商品的属性,默认来至于所属的分类
    # 所为,必须要测试分类的属性的转换,对其产生的影响
    describe "附加属性" do
        let(:apple) { Product.first }
        let(:material) { Property.where(:name => 'material').first }
        let(:weight) { Property.where(:name => 'weight').first }
        let(:clothes_type) { Property.where(:name => 'clothes_type').first }

        let(:pants) { PropertyValue.first }

        # properties 将包含 商品的属性表 Property
        # Property
        #   name: string 类型,属性的名称
        #   title: string 类型, 标题显示
        #   property_type: string 类型, 属性类型, 包含 Integer, String , BigDecimal, DateTime, Set(集合)等
        it "包含属性" do
            apple.properties.should include(material, weight, clothes_type)
        end

        # properties_values
        it "属性存值" do
            apple.properties_values.should include(pants)
        end

        describe "直接访问属性方法" do
            it "material" do
                apple.should respond_to(:material)
            end

            it "weight" do
                apple.should respond_to(:weight)
            end

            it "clothes_type" do
                apple.should respond_to(:clothes_type)
            end

            it "material 存值" do
                apple.material.should eql("cotton")
                apple.material = "leather"
                apple.material.should == "leather"
            end

            it "weight 存值" do
                apple.weight.should be_nil
                apple.weight = 28
                apple.weight.should == 28
            end

            it "clothes_type 存值" do
                apple.clothes_type.should == "Pants"
                apple.clothes_type = "Hat"
                apple.clothes_type.should == "Hat"
            end

            describe "存储有效" do
                it "material 存值" do
                    apple.material.should eql("cotton")
                    apple.material = "leather"
                    apple.material.should == "leather"
                    apple.save

                    Product.first.material.should == "leather"
                end

                it "weight 存值" do
                    apple.weight.should be_nil
                    apple.weight = 28
                    apple.weight.should == 28
                    apple.save

                    Product.first.weight.should == 28
                end

                it "clothes_type 存值" do
                    apple.clothes_type.should == "Pants"
                    apple.clothes_type = "Hat"
                    apple.clothes_type.should == "Hat"
                    apple.save

                    Product.first.clothes_type.should == "Hat"
                end
            end

            describe "不同的分类,商品属性不一样" do
                let(:make_in) { Property.where(:name => 'make_in').first }
                let(:flavor) { Property.where(:name => 'flavor').first }
                let(:color) { Property.where(:name => 'color').first }

                it "挂接分类" do
                    apple.properties.should include(material, weight, clothes_type)
                    apple.category = Category.find(71)
                    apple.attach_properties!
                    apple.should have(0).properties
                end

                it "挂接另一个有属性的分类" do
                    apple.properties.should include(material, weight, clothes_type)
                    apple.category = Category.find(72)
                    apple.attach_properties!
                    apple.properties.should include(make_in, flavor, color)
                end


                it "直接访问新的有属性" do
                    apple.category = Category.find(72)
                    apple.attach_properties!

                    apple.should_not respond_to(:material)
                    apple.should respond_to(:make_in)
                    apple.should respond_to(:flavor)
                    apple.should respond_to(:color)
                end

                it "直接写新的属性" do
                    apple.category = Category.find(72)
                    apple.attach_properties!

                    apple.make_in = "China"
                    apple.flavor = "rich"
                    apple.make_in.should eql("China")
                    apple.flavor.should eql("rich")
                end

                it "直接写新的属性 - 保存" do
                    apple.category = Category.find(72)
                    apple.attach_properties!

                    apple.make_in = "China"
                    apple.flavor = "rich"
                    apple.save

                    Product.first.make_in.should eql("China")
                    Product.first.flavor.should eql("rich")
                end

                it "直接写新的属性 - 保存" do
                    apple.category = Category.find(72)
                    apple.attach_properties!

                    apple.make_in = "China"
                    apple.flavor = "rich"
                    apple.save

                    Product.first.make_in.should eql("China")
                    Product.first.flavor.should eql("rich")
                end

                it "未建立 product_property 关系的写值 - 保存" do
                    apple.category = Category.find(72)
                    apple.attach_properties!

                    apple.make_in = "China"
                    apple.flavor = "rich"
                    apple.provider = "WanLiu"
                    apple.save

                    Product.first.make_in.should eql("China")
                    Product.first.flavor.should eql("rich")
                    Product.first.provider.should eql("WanLiu")
                end

                it "更换分类移出原有值" do
                    apple.material.should == "cotton"
                    apple.category = Category.find(71)
                    apple.attach_properties!
                    apple.properties_values.size.should == 0
                    apple.save
                    # PropertyValue.all.size.should eql(3)
                end
            end
        end

        describe "同步附加属性" do
            let(:category) { apple.category }
            let(:sizes) { Property.find(12) }
            let(:colour) { Property.find(11) }

            it "同步价格方案" do
                category.price_options.create(:property => sizes)
                category.price_options.create(:property => colour)
                apple.attach_properties!
                apple.prices_definition.should include(sizes, colour)
            end
        end
    end
  end
end
