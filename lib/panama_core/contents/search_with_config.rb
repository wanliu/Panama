# encoding: utf-8
require File.expand_path('../resource_type', __FILE__)

module PanamaCore
  module Contents
    class SearchWithConfig

      attr_reader :rtype, :action, :resource
      cattr_accessor :default_data_adapter

      @@default_data_adapter = Content

      def initialize(resource, action = nil)
        @rtype = ResourceType.new(resource, action)
        @resource = resource
        @action = action
      end

      def action
        @action || config_list.default_action
      end

      def fetch(options = {})

        if query.size > 0
          # 查找到
          query.first
        # elsif options[:autocreate]
        #   # 如果 options :autocreate 为真,将自动创建 resource for action 的 content 条目
        #   create_for(resource, action)
        else
          # contents 里没有记录

          return nil if config.nil?
          # 没有此规则, 只能返回空

          if config.default_config.present?
            # 此时是没有找到 Content 条目,但有配置项, 所以我们要检查,是不是有默认跳转?

            transfer_name       = config.default_config[:config]
            transfer_method     = config.default_config[:transfer_method]
            transfer_action     = config.default_config[:transfer_action] || action
            # transfer_autocreate = config.default_config[:autocreate]      || false

            new_resource = resource.send(transfer_method)
            self.class.fetch_for(new_resource, transfer_action)
          else
            # 没有默认跳转的话,我们要返回一个非永久 content 条目
            result = generate_result(options)

            path = File.join(result[:root], result[:template])

            params = { :name             => rtype.unique_name,
                       :template         => path,
                       :contentable_type => rtype.resource_class,
                       :contentable_id   => rtype.resource_id }
            query.first_or_initialize(params)
          end

        end

      end

      def config_list
        rtype.config_list
      end

      def compile_config(locals = default_options)
        locals ||= {}
        result = {}
        [:root, :template].each do |method_name|
          result[method_name] = config.send(method_name).sub /\:(\w+)/ do |m|
            name = m[1..-1].to_sym
            locals[name]
          end
        end
        result
      end

      def generate_result(options)
        compile_config(default_options.deep_merge(options))
      end

      def config_list
        klass_name = rtype.symbolize_resource_class
        if rtype.resource_id > 0
          contents_config[klass_name][:each]
        else
          contents_config[klass_name]
        end
      end

      def config
        config_list[action]
      end

      def contents_config
        Rails.application.config.contents
        # PanamaCore::Contents.contents_config
      end

      def default_options
        { :locals => { :name => action }}
      end

      def query
        adapter.where(:name => rtype.unique_name)
      end

      def create( options = {})
        raise ArgumentError.new('invalid resource or action') if config.nil?

        result = generate_result(options)

        path = File.join(result[:root], result[:template])

        adapter.create(:name             => rtype.unique_name,
                       :template         => path,
                       :contentable_type => rtype.resource_class,
                       :contentable_id   => rtype.resource_id)
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

        def create_for
          new(resource, action).query(options)
        end
      end
    end
  end
end