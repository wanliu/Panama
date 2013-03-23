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

      def nil_transfer(value, options = {})
        @config[:default] = { :config => value }.merge(options)
      end

      def default_action(value, options = {})
        @config[:default_action] = value
        @config[value] = Config[default_config(options)]
      end

      def each(&block)
        child :each, &block
      end

      def method_missing(method_name, *args, &block)
        return super if @_stabilization
        if block_given?
          child method_name, *args, &block
        else
          if method_name == :default
            send(:nil_transfer, *args, &block)
          else
            @config[method_name] = Config[default_config(args.first)]
          end
        end
      end

      protected

      def child(name, *args, &block)
        _child = @config[name] = Config.new
        _child[:parent] = @config
        # _child[:root] = @root
        # _child[:template] = @template
        # _child[:layout_path] = @layout_path
        options = args.first || {}
        Builder.new(_child, options, &block)
      end

      def default_config(params = {})
        params ||= {}
        { :root        =>         @config[:root],
          :parent      =>       @config[:parent],
          :template    =>     @config[:template],
          :layout_path =>  @config[:layout_path] }.merge(params)
      end

      def _stabilize(&block)
        @_stabilization = true
        yield
        @_stabilization = false
      end
    end
  end
end