require 'delegate'

module PanamaCore
  module Contents

    def self.reload_proxy_content_by_spork?
      _klass = const_get(:ProxyContent)
      if Rails.env.test? && _klass.is_a?(Class)
        remove_const(:ProxyContent)
        return true
      else
        false
      end
    rescue NameError
      return true
    end

    if reload_proxy_content_by_spork?
      class ProxyContent < DelegateClass(Content)

        attr_accessor :object

        attr_accessor :config, :locals, :root

        def initialize(content, config, locals)
          super(content)
          @object = content
          @config = config
          @locals = locals
        end

        def template
          result = compile_config
          @root = result[:root].to_dir
          _template = super
          Template.new(_template, @root)
        end

        def layout
          @layouts_path = @config.layout_path.to_dir
          @layouts_path[@config.layout]
        end

        def compile_config
          result = {}
          [:root, :template].each do |method_name|
            _item = config[method_name]
            result[method_name] = _item.sub /\:(\w+)/ do |m|
                                    name = m[1..-1].to_sym
                                    locals[name]
                                  end
          end
          result
        end
      end
    end
  end
end
