# encoding: utf-8
require 'spec_helper'

describe PanamaCore::Contents do

  let(:pepsi) { Shop.first }

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
  end

  # fetch_for(resource, name, options, &block)
  # fetch_for 的应用场景
  # Content.fetch_for 用来获取"资源"的 content 对象, fetch_for 根据 resource 与 name 生成的名称,进行查询
  # Content 对象本身存储了 template 等相关信息
  #
  # fetch_for 依据
  # ## fetch_for 会在
  describe "#getch_for" do

    def do_config(&block)
      PanamaCore::Contents.config(&block)
    end


    describe "fetch_for 测试一" do

      before :each do

        config = do_config do
          root '/panama'
          template 'templates/:name.html.erb'
          layout_path 'layouts'

          default :show

          category do

            default_additional_properties

            each do
              additional_properties :default => :default_additional_properties
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

            each do
              sale_options :default => 'category#sale_options'
              additional_properties :default => 'category#additional_properties', :transfer => :category
            end
          end
        end

      end

      it "无附加名时,返回默认 show" do
        @category = Category.first
        content = PanamaCore::Contents.fetch_for(@category)
      end

      # it "Shop Index" do
      #   content = Content.fetch_for(pepsi, :index)
      #   content.template
      # end

      # it "Shop Index" do
      #   content = Content.fetch_for(pepsi, :index)
      # end
    end

    it "shop :index" do
      pepsi = Shop.first
      content = PanamaCore::Contents.fetch_for(pepsi, :index, :locals => { :shop_name => pepsi.name })
      puts content
    end

    it "product" do
      content = PanamaCore::Contents.fetch_for(Product.first, :sale_options)
      content.persisted?.should be_false
    end

    it "render" do
      # render_content(@product, :sale_options, :locals => { :shop_name => pepsi.name })
    end
  end
end