# encoding: utf-8
require 'spec_helper'

describe PanamaCore::Contents do

  def do_config(&block)
    PanamaCore::Contents.config(&block)
  end

  let(:pepsi) { Shop.first }

  before :each do

    config = do_config do
      root '/panama'
      template 'templates/:action.html.erb'
      layout_path 'layouts'

      default_action :show

      category do
        default_additional_properties

        each do
          template 'templates/category_:id,_:action.html.erb'
          additional_properties :transfer => :default_additional_properties
          sale_options
        end
      end

      shop do
        root '/_shops/:shop_name'

        each do
          index
        end
      end

      product do
        root '/_shops/:shop_name'
        template 'templates/:class_name,_:id,_:action.html.erb'

        each do
          sale_options :transfer => 'category#sale_options'
          additional_properties :transfer => 'category#additional_properties', :transfer_method => :category
        end
      end
    end
  end

  it "#to_result" do
    content = PanamaCore::Contents.fetch_for(pepsi, :index, :locals => { :shop_name => pepsi.name })
    # result.template.should eql("templates/test.html.erb")
  end

  # create_for(resource, name, options, &block)
  # 创建 "资源" 的 Content 对象, 会依据 PanamaCore::Content.config 的配置,自动创建这一条目
  # 包括: template , 根存储
  # 例子:
  #   Content.create_for(pepsi, :index, :locals => { :shop_name => pepsi.name })
  describe "#create_for" do

    describe "查询并创建" do
      it "无附加名时,返回默认 show" do
        @category = Category.first
        content = PanamaCore::Contents.fetch_for(@category, :autocreate => true)
        content.name.should match /show/
        content.persisted?.should be_true
      end

      it "分类的 additional properties(附加属性)" do
        @category = Category.first
        content = PanamaCore::Contents.fetch_for(@category, :additional_properties, autocreate: true)
        content.name.should match /category_\d+_additional_properties/
        content.template.should be_a(Template)
        content.template.path.should match %r(templates/category_\d+_additional_properties.html.erb)
      end

      it "Shop Index" do
        content = PanamaCore::Contents.fetch_for(pepsi, :index, :autocreate => true, :locals => { :shop_name => pepsi.name })
        content.name.should match /shop_\d+_index/
        content.template.path.should match %r(/_shops/\w+/templates/index.html.erb)
        content.persisted?.should be_true
      end

      it "Shop 默认" do
        content = PanamaCore::Contents.fetch_for(pepsi, :autocreate => true, :locals => { :shop_name => pepsi.name })
        content.name.should match /shop_\d+_show/
        content.template.path.should match %r(/_shops/\w+/templates/show.html.erb)
        content.persisted?.should be_true
      end

      it "product :sale_options" do
        content = PanamaCore::Contents.fetch_for(Product.first,
                                                 :sale_options,
                                                 :autocreate => true,
                                                 :locals => { :shop_name => pepsi.name })
        content.name.should match /product_\d+_sale_options/
        content.template.path.should match %r(templates/product_\d+_sale_options)
        content.persisted?.should be_true
      end

      it "product :additional_properties" do
        content = PanamaCore::Contents.fetch_for(Product.first,
                                                 :additional_properties,
                                                 :autocreate => true,
                                                 :locals => { :shop_name => pepsi.name })
        content.name.should match /product_\d+_additional_properties/
        content.template.path.should match %r(templates/product_\d+_additional_properties)
        content.persisted?.should be_true
      end
    end
  end

  # fetch_for(resource, name, options, &block)
  # fetch_for 的应用场景
  # PanamaCore::Contents.fetch_for 用来获取"资源"的 content 对象, fetch_for 根据 resource 与 name 生成的名称,进行查询
  # Content 对象本身存储了 template 等相关信息
  #
  # fetch_for 依据
  # ## fetch_for 会在
  describe "#getch_for" do


    describe "默认 fetch_for 测试, 无设定 content" do

      it "无附加名时,返回默认 show" do
        @category = Category.first
        content = PanamaCore::Contents.fetch_for(@category)
        content.name.should match /show/
      end

      it "分类的 additional properties(附加属性)" do
        @category = Category.first
        content = PanamaCore::Contents.fetch_for(@category, :additional_properties)
        content.name.should match /category_default_additional_properties/
        content.should_not be_nil
        content.template.should be_a(Template)
        content.template.path.should match %r(templates/default_additional_properties.html.erb)
      end

      it "Shop Index" do
        content = PanamaCore::Contents.fetch_for(pepsi, :index, :locals => { :shop_name => pepsi.name })
        content.name.should match /shop_\d+_index/
        content.template.path.should match %r(templates/index.html.erb)
      end

      it "Shop 默认" do
        content = PanamaCore::Contents.fetch_for(pepsi, :locals => { :shop_name => pepsi.name })
        content.name.should match /shop_\d+_show/
        content.template.path.should match %r(templates/show.html.erb)
      end

      it "product :sale_options" do
        content = PanamaCore::Contents.fetch_for(Product.first, :sale_options)
        content.name.should match /category_\d+_sale_options/
        content.template.path.should match %r(templates/category_\d+_sale_options.html.erb)
        content.persisted?.should be_false
      end

      it "product :additional_properties" do
        content = PanamaCore::Contents.fetch_for(Product.first, :additional_properties)
        content.name.should match /category_default_additional_properties/
        content.template.path.should match %r(templates/default_additional_properties)
        # 会转向默认配置 default_additional_properties
        content.persisted?.should be_false
      end
    end

    describe "有 Content 数据的情况下的 fetch_for" do
      before :each do
        @category = Category.first
        @category.class
        @product = Product.first
        Content.create(:name => "category_#{@category.id}_show", :template => "category_#{@category.id}_show.html.erb", :contentable => @category)
        # create cateory_53_show :name content
        Content.create(:name => "category_#{@category.id}_additional_properties", :template => "templates/additional_properties.html.erb", :contentable => @category)
        # create cateory_53_additional_properties :name content
        Content.create(:name => "shop_#{pepsi.id}_index", :template => "templates/pepsi_index.html.erb", :contentable => pepsi)
        Content.create(:name => "shop_#{pepsi.id}_show", :template => "templates/pepsi_show.html.erb", :contentable => pepsi)

        Content.create(:name => "product_#{@product.id}_sale_options", :template => "templates/product_#{@product.id}_sale_options.html.erb", :contentable => @product)
        Content.create(:name => "product_#{@product.id}_additional_properties", :template => "templates/product_#{@product.id}_additional_properties.html.erb", :contentable => @product)
      end

      it "无附加名时,返回默认 show" do
        content = PanamaCore::Contents.fetch_for(@category)
        content.name.should match /show/
        content.template.path.should match %r(category_\d+_show.html.erb)
        # 会使用自己的设定的模板
      end

      it "分类的 additional properties(附加属性)" do
        content = PanamaCore::Contents.fetch_for(@category, :additional_properties)
        content.name.should match /category_\d+_additional_properties/
        content.should_not be_nil
        content.template.should be_a(Template)
        content.template.path.should match %r(templates/additional_properties.html.erb)
      end

      it "Shop Index" do
        content = PanamaCore::Contents.fetch_for(pepsi, :index, :locals => { :shop_name => pepsi.name })
        content.name.should match /shop_\d+_index/
        content.template.path.should match %r(templates/pepsi_index.html.erb)
      end

      it "Shop 默认" do
        content = PanamaCore::Contents.fetch_for(pepsi, :locals => { :shop_name => pepsi.name })
        content.name.should match /shop_\d+_show/
        content.template.path.should match %r(templates/pepsi_show.html.erb)
      end

      it "product :sale_options" do
        content = PanamaCore::Contents.fetch_for(Product.first,
                                                 :sale_options,
                                                 :locals => { :shop_name => pepsi.name })
        content.name.should match /product_\d+_sale_options/
        content.template.path.should match %r(templates/product_\d+_sale_options)
        content.persisted?.should be_true
      end

      it "product :additional_properties" do
        content = PanamaCore::Contents.fetch_for(Product.first,
                                                 :additional_properties,
                                                 :locals => { :shop_name => pepsi.name })
        content.name.should match /product_\d+_additional_properties/
        content.template.path.should match %r(templates/product_\d+_additional_properties)
        # 会转向默认配置 default_additional_properties
        content.persisted?.should be_true
      end
    end
  end
end