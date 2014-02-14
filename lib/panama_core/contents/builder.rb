module PanamaCore
  module Contents
    class Builder

      attr_reader :config

      def initialize(config = nil, options = {}, &block)

        @config = if !config.nil?
                    # @parent = config.delete :parent
                    # @root = config.delete :root
                    # @template = config.delete :template
                    # @layout_path = config.delete :layout_path
                    config
                  else
                    Config.new
                  end

        @config.merge!(options)

        instance_exec(&block)
      end

      def root(value)
        @config[:root] = value
      end

      def template(value)
        @config[:template] = value
      end

      def layout_path(value)
        @config[:layout_path] = value
      end

      def transfer(value, options = {})
        hash = { :config => transfer_action(value) }
        if options[:transfer_method].nil? && value.is_a?(String)
          if /(?<prefix>\w+)#|::/ =~ value
            options[:transfer_method] = prefix
          else
            raise ArgumentError.new('You must use correct value in transfer(value,...) ')
          end
        end
        @config[:transfer] = hash.merge(options)
      end

      def default_action(value, options = {})
        @config[:default_action] = value
        @config[value] = Config[default_config(value, options)]
      end


      def each(&block)
        child :each, &block
      end

      def method_missing(method_name, *args, &block)
        return super if @_stabilization
        if block_given?
          child method_name, *args, &block
        else
          @config[method_name] = Config[default_config(method_name, args.first)]
        end
      end

      protected

      def child(name, *args, &block)
        _child = @config[name] = Config.new
        _child[:name]   = name
        _child[:parent] = @config
        options            = args.first || {}
        options[:transfer] = extract_transfer_options(options) unless options[:transfer].nil?
        Builder.new(_child, options, &block)
      end

      def default_config(name, params = {})
        params ||= {}
        # extract_transfer_options(params)
        params[:transfer] = extract_transfer_options(params)

        { :name        =>                   name,
          :root        =>         @config[:root],
          :parent      =>       @config[:parent],
          :template    =>     @config[:template],
          :layout_path =>  @config[:layout_path] }.merge(params)
      end

      def extract_transfer_options(options)
        _config = transfer_config(options[:transfer])
        if options[:transfer].is_a?(String) && options[:transfer_method].nil?
          # 没有设置 transfer_method && transfer = '字符串'
          # example:
          #   sale_options :transfer => 'category#sale_options'
          if /(?<prefix>\w+)#|::/ =~ options[:transfer]
            options.delete(:transfer_method)
            _config[:transfer_method] = prefix.to_sym
          else
            raise ArgumentError.new('You must use correct value in transfer(value,...) ')
          end
        elsif options[:transfer_method]
          _config[:transfer_method] = options[:transfer_method]
        end
        _config
      end

      def top
        @config.top
      end

      def transfer_config(params)
        case params
        when Symbol
          config, _method = if @config[params]
                              [@config[params], nil]
                            elsif @config.parent[params]
                              [@config.parent[params], :class]
                            # elsif @config.parent.parent[config]
                            #   [@config.parent.parent[config], :class]
                            end
          { :config => config, :transfer_method => _method }
        when String
          { :config => transfer_action(params) }
        when NilClass
          { :config => nil }
        end
      end

      def transfer_action(config)
        case config
        when /#/
          # 实体属性
          resource_name, action = config.split('#').map(&:to_sym)
          @config.top[resource_name][:each][action]
        when /::/
          resource_name, action = config.split('::').map(&:to_sym)
          @config.top[resource_name][action]
        else
          @config[config.to_sym]
        end
      end

      def _stabilize(&block)
        @_stabilization = true
        yield
        @_stabilization = false
      end
    end
  end
end