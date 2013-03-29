# encoding: utf-8
require 'spec_helper'
require 'panama_core/contents'

describe PanamaCore::Contents::Config do

  describe "Content 配置测试" do

    def do_config(&block)
      PanamaCore::Contents::Builder.new(nil, &block).config
    end

    describe "期础选项" do

      it "定义顶级 root" do
        config = do_config do
                   root '/panama'

                   category
                 end
        config.root.should eql("/panama")
        config[:category].root.should eql("/panama")
      end

      it "定义顶级 template" do
        config = do_config do
                   root '/panama'
                   template 'templates/test.html.erb'

                   category
                 end

        config.root.should eql("/panama")
        config.template.should eql("templates/test.html.erb")
      end

      it "定义顶级 layout_path" do
        config = do_config do
                   root '/panama'
                   template 'templates/test.html.erb'
                   layout_path 'layouts'

                   category
                 end
        config.root.should eql("/panama")
        config.template.should eql("templates/test.html.erb")
        config.layout_path.should eql("layouts")
      end

      it "不同的层级的 root" do
        config = do_config do
                   root '/panama'

                   category do
                     root '/test'

                   end
                 end

        config.root.should eql("/panama")
        config[:category].root.should eql("/test")
      end

      it "不同的层级的 template" do
        config = do_config do
                   root '/panama'
                   template 'templates/test.html.erb'

                   category do
                     template 'change_template'

                   end
                 end

        config.root.should eql("/panama")
        config[:category].template.should eql("change_template")
      end


      it "不同的层级的 layout_path" do
        config = do_config do
                   root '/panama'
                   layout_path 'layouts'

                   category do
                     layout_path 'layouts/test'

                   end
                 end

        config.root.should eql("/panama")
        config[:category].layout_path.should eql("layouts/test")
      end
    end

    describe "分类规则" do

      it "两个分类" do
        config = do_config do
                   root '/panama'
                   layout_path 'layouts'

                   category do
                     root '/categories'

                   end

                   product do

                    root '/products'
                   end
                 end

        config.root.should eql("/panama")
        config[:category].root.should eql("/categories")
        config[:product].root.should eql("/products")
      end
    end


    describe "Each 规则" do

      it "index" do
        config = do_config do
                   root '/panama'
                   template 'templates/test.html.erb'
                   layout_path 'layouts'

                   shop do
                     each do
                       # index 页, 默认的 layout 等于 :index
                       index :layout => :index
                     end
                   end
                 end

        config[:shop][:each][:index].root.should eql("/panama")
        # 使用模板 :index
        config[:shop][:each][:index][:layout].should eql(:index)
        config[:shop][:each][:index].layout.should eql('layouts/index.html.erb')
        config[:shop][:each][:index].template.should eql('templates/test.html.erb')
      end
    end

    describe "转向规则" do

      it "规则内转向" do

        config = do_config do
                   root '/panama'
                   template 'templates/test.html.erb'
                   # 定义分类 Category 类型对象的 配置
                   category do

                     root '/panama/categories'

                     default_additional_properties do
                       template 'templates/additional_properties.html.erb'
                     end

                     # each 类实体的规则, 以下包括 additional_properties
                     each do

                       # additional_properties 规则, 有一个默认回逆配制, 如果相应的配置没有在 Content 中
                       # 存在的话, 会自动转向默认配置, 使用默认配置的设置,来进行 render
                       additional_properties :transfer => :default_additional_properties do
                         # 配置项中的附加条款, created_copy_from_default 创建时会从默认回逆那里,拷贝数据过来
                         created_copy_from_default
                       end

                       sale_options
                     end
                   end
                 end

        config.root.should == "/panama"
        config[:category][:default_additional_properties].root.should == "/panama/categories"
        config[:category][:default_additional_properties].template.should == "templates/additional_properties.html.erb"

        transfer_config = config[:category][:each][:additional_properties].transfer_config
        # transfer_config
        transfer_config.template.should == 'templates/additional_properties.html.erb'
        transfer_config.root.should == '/panama/categories'
      end

      it "夸规则转向" do
        config = do_config do
                   root '/panama'
                   template 'templates/:action.html.erb'

                   category do
                    root '/panama/categories'
                    template 'templates/:category_id.html.erb'

                    each do
                      sale_options
                    end
                   end

                   product do
                     # root '/panama'
                     root '/_shops/:shop_name'
                     # 你可以为资源设定一个默认页面,也就是没有 指定 fetch_for(resource, name ) name 参数时,会附加的页面
                     # 同样这是一个回逆配置
                     default_action :show

                     each do
                       # 默认回逆配置, 可以转向其它资源的配置, 如下: sale_options 可以转向到 Category 的 sale_options
                       # 这种情况,保证了我们在找到此 Product 的 :sale_options Content 时,会转向 transfer 到另一资源
                       # 的这种情况, :transfer , :transfer_method 分别设定了, 转向的资源所执行的代码块或方法.
                       sale_options do
                         transfer 'category#sale_options', :transfer_method => :category
                       end
                     end
                   end
                 end

        config.root.should == "/panama"
        config[:product].root.should      == "/_shops/:shop_name"
        config[:product][:default_action].should == :show

        config[:product][:show].root.should == '/_shops/:shop_name'

        transfer_config = config[:product][:each][:sale_options].transfer_config
        transfer = config[:product][:each][:sale_options].transfer
        transfer_config.root.should      == '/panama/categories'
        transfer_config.template.should  == 'templates/:category_id.html.erb'
        transfer[:transfer_method].should  == :category
      end

      it "默认 action" do
        config = do_config do
                   root '/panama'
                   template 'templates/:action.html.erb'

                   default_action :show

                   category do
                    root '/panama/categories'
                    template 'templates/:category_id.html.erb'

                    each do
                      sale_options
                    end
                   end
                 end

        config.root.should == "/panama"
        config[:category][:each][:sale_options].default_action.should == :show
        config[:category][:each].default_action.should == :show
        config[:category].default_action.should == :show

      end
    end
  end
end