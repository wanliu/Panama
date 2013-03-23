module PanamaCore
  module Contents

    class Config < Hash
      TRANSFERS_WORD = [:root, :template, :layout_path, :default_action]

      def root
        get :root
      end

      def template
        get :template
      end

      def parent
        get :parent
      end

      def layout_path
        get :layout_path
      end

      def default_config
        get :default
      end

      def default_action
        get [:default_action]
      end

      def [](key)
        value = super
        case value
        when Hash
          Config[value]
        when NilClass
          if TRANSFERS_WORD.include?(key)
            parent[key] unless parent.nil?
          end
        else
          value
        end
      end

      def to_result(locals)
        hash = Config.new
        [:root, :template].each do |config|
          item = get(config)
          unless item.blank?
            hash[config] = item.sub /(\:\w+)/ do |_name|
                             name = _name[1..-1]
                             value = locals[name.to_sym]
                             if value.nil?
                               raise ArgumentError.new("need named #{name} of key in :locals arguments!")
                             else
                               value
                             end
                           end
          end
        end
        hash
      end

      protected

      def get(name)
        send(:[], name)
      end
    end
  end
end