# encoding: utf-8
require File.expand_path('../contents/builder', __FILE__)
require File.expand_path('../contents/config', __FILE__)
# require File.expand_path('../contents/render', __FILE__)
require File.expand_path('../contents/proxy_content', __FILE__)
require File.expand_path('../contents/search_with_config', __FILE__)

module PanamaCore
  module Contents
    extend self
    # include Render
    # 基础格式
    # PanamaCore::Contents.config do
    #
    #   # 定义默认的根
    #   root '/panama'
    #   # 默认的模板格式, :name 是可替换变量
    #   template 'templates/:name.html.erb'
    #   # 可以控制渲染的布局
    #   layout_path 'layouts'
    #
    #
    #   # 定义分类 Category 类型对象的 配置
    #   category do
    #
    #
    #     default_additional_properties do
    #       template 'templates/additional_properties.html.erb'
    #     end
    #
    #     # each 类实体的规则, 以下包括 additional_properties
    #     each do
    #
    #       # additional_properties 规则, 有一个默认回逆配制, 如果相应的配置没有在 Content 中
    #       # 存在的话, 会自动转向默认配置, 使用默认配置的设置,来进行 render
    #       additional_properties :default => :default_additional_properties do
    #         # 配置项中的附加条款, created_copy_from_default 创建时会从默认回逆那里,拷贝数据过来
    #         created_copy_from_default
    #       end
    #
    #       sale_options
    #     end
    #   end
    #
    #   shop do
    #     # 相对配置, 这使得 Shop 类的配置, 与其它配置是不同的, 在 Shop 里, 根路径是 /_shops/:shop_name
    #     root '/_shops/:shop_name'
    #     template: 'templates/:name.html.erb'
    #
    #     # 定义布局 :index ,存储在 /panama/layouts
    #     layout :index
    #
    #     each do
    #       # index 页, 默认的 layout 等于 :index
    #       index :layout => :index
    #     end
    #
    #   end
    #
    #   product do
    #     # root '/panama'
    #     root '/_shops/:shop_name'
    #
    #     # 你可以为资源设定一个默认页面,也就是没有 指定 fetch_for(resource, name ) name 参数时,会附加的页面
    #     # 同样这是一个回逆配置
    #     default　:show
    #
    #     each do
    #       # 默认回逆配置, 可以转向其它资源的配置, 如下: sale_options 可以转向到 Category 的 sale_options
    #       # 这种情况,保证了我们在找到此 Product 的 :sale_options Content 时,会转向 transfer 到另一资源
    #       # 的这种情况, :transfer , :transfer_method 分别设定了, 转向的资源所执行的代码块或方法.
    #       sale_options do
    #         default 'category#sale_options', :transfer_method => :category
    #       end
    #     end
    #   end
    # end
    #
    # # views/products/show.html.erb
    # <%= render_content(@product, :sale_options) %>
    #
    attr_accessor :contents_config

    def contents_config=(value)
      @contents_config = value
    end

    def config(&block)
      builder = Builder.new(nil, &block)
      if defined?(Rails)
        Rails.application.config.contents = builder.config
      else
        builder.config
      end
    end

    def fetch_for(resource, *args)
      options = args.extract_options!
      action = args.first
      SearchWithConfig.fetch_for(resource, action, options)
    end

    def create_for(resource, *args)
      options = args.extract_options!
      action = args.first
      SearchWithConfig.create_for(resource, aciton, options)
    end

    def query_for(resource, *args)
      options = args.extract_options!
      action = args.first
      SearchWithConfig.query_for(resource, aciton, options)
    end

  end
end