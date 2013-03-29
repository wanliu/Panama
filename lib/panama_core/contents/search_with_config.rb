# encoding: utf-8
require File.expand_path('../resource_type', __FILE__)
require File.expand_path('../proxy_content', __FILE__)

module PanamaCore
  module Contents
    class SearchWithConfig

      attr_reader :rtype, :action, :resource, :config
      cattr_accessor :default_data_adapter

      @@default_data_adapter = Content

      def initialize(resource, _action = nil, options = {})
        @rtype = ResourceType.new(resource, _action)
        @resource = resource
        @config = options[:config] if options[:config].present?
        @action = _action
        set_rtype_action(default_action) if _action.nil?
      end

      def set_rtype_action(value)
        @rtype.instance_variable_set(:@action, value)
      end

      def action
        @action
      end

      def default_action
        config_list.default_action
      end

      def config
        @config ||= if !@config.nil?
                      @config
                    else
                      _action = action.nil? ? default_action : action
                      if action.nil?
                        generate_config(_action)
                      else
                        config_list[_action]
                      end
                    end
      end

      def revert_config(_action)
        _config = config_list[_action]
        parent = config_list.parent
        while parent.present?
          _config = parent[_action]
          parent = parent.parent
        end
        _config
      end

      def generate_config(_action)
        Config[{ name:         _action,
                 root:         config_list.root,
                 template:     config_list.template,
                 parent:       config_list,
                 layout_path:  config_list.layout_path }]
      end

      def fetch(options = {})
        @config ||= options[:config]
        locals_options = default_options.deep_merge(options[:locals] || {})

        if query.size > 0
          # 查找到
          ProxyContent.new(query.first, config, locals_options)
        elsif options[:autocreate]
          # 如果 options :autocreate 为真,将自动创建 resource for action 的 content 条目
          self.class.create_for(resource, action, options)
        else
          # contents 里没有记录

          return nil if config.nil?
          # 没有此规则, 只能返回空
          if config.transfer.present? && config.transfer_config.present?
            # 此时是没有找到 Content 条目,但有配置项, 所以我们要检查,是不是有默认跳转?

            transfer_config = config.transfer_config
            transfer_method = config.transfer[:transfer_method]
            transfer_action = config.transfer[:transfer_action] || transfer_config.name
            # transfer_autocreate = config.transfer[:autocreate] || false

            new_resource = transfer_method.nil? ? resource : resource.send(transfer_method)
            self.class.fetch_for(new_resource, transfer_action, config: transfer_config)
          else
            # 没有默认跳转的话,我们要返回一个非永久 content 条目
            result = generate_result(locals_options)
            # path = File.join(result[:root], result[:template])
            path = result[:template]

            params = { :name             => rtype.unique_name,
                       :template         => path,
                       :contentable_type => rtype.resource_class.to_s,
                       :contentable_id   => rtype.resource_id }

            ProxyContent.new(query.first_or_initialize(params), config, locals_options)
          end

        end

      end

      def compile_config(locals = default_options)
        locals ||= {}
        result = {}
        [:root, :template].each do |method_name|
          _item = config[method_name]
          result[method_name] = _item.gsub /\:(\w+),?/ do |m|
                                  e = m[-1] == ',' ? -2 : -1
                                  name = m[1..e].to_sym
                                  raise ArgumentError.new("lost named: #{name} parameter in this locals of options") if locals[name].nil?
                                  locals[name]
                                end
        end
        result
      end

      def generate_result(options)
        compile_config(default_options.deep_merge(options))
      end

      def default_options
        { :action => action || default_action,
          :id => rtype.resource_id,
          :unique_name => rtype.unique_name,
          :class_name => rtype.symbolize_resource_class
        }
      end

      def query
        adapter.where(:name => rtype.unique_name)
      end

      def create(options = {})
        locals_options = default_options.deep_merge(options[:locals] || {})
        raise ArgumentError.new('invalid resource or action') if config.nil?

        result = generate_result(locals_options)

        path = result[:template]

        ProxyContent.new(adapter.create(:name             => rtype.unique_name,
                                        :template         => path,
                                        :contentable_type => rtype.resource_class,
                                        :contentable_id   => rtype.resource_id),
                         config,
                         locals_options)
      end

      # alias_method :generate_result, :compile_config
      alias_method :adapter        , :default_data_adapter

      class << self

        def fetch_for(resource, action = nil, options = {})
          new(resource, action).fetch(options)
        end

        def query_for(resource, action = nil, options = {})
          new(resource, action).query
        end

        def create_for(resource, action = nil, options = {})
          new(resource, action).create(options)
        end
      end

      private

      def config_list
        klass_name = rtype.symbolize_resource_class
        if rtype.resource_id > 0
          contents_config[klass_name][:each]
        else
          contents_config[klass_name]
        end
      end

      def contents_config
        Rails.application.config.contents
        # PanamaCore::Contents.contents_config
      end
    end
  end
end