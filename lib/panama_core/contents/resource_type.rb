module PanamaCore
  module Contents

    class ResourceType

      attr_reader :action, :resource

      def initialize(resource, action = nil)
        @resource = resource
        @action = action
      end

      def action
        @aciton
      end

      def resource_class
        case @resource
        when Class
          @resource
        when ActiveRecord::Base
          @resource.class
        end
      end

      def resource_id
        case @resource
        when Class
          0
        when ActiveRecord::Base
          @resource.id || 1.0 / 0
        end
      end

      def symbolize_resource_class
        resource_class.to_s.underscore.to_sym
      end

      def resource_name
        class_name = resource_class.to_s.underscore
        if resource_id == 0
          class_name
        else
          [class_name, resource_id].join('_')
        end
      end

      def unique_name
        names = [resource_name, @action]
        names.delete(nil)
        names.join('_')
      end

    end
  end
end