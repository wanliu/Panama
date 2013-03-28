require 'active_support/concern'
require 'acts_as_status/status'

module ActsAsStatus
  extend ::ActiveSupport::Concern

  module ClassMethods
    def acts_as_status(field, status)
      
      self.instance_eval do
        attr = "#{field}".to_sym

        define_method "#{field}" do          
          Status.new(read_attribute(attr), status.uniq)
          # Status.default_convert(self[attr], status)          
        end

        define_method "#{field}=" do | value |
          s = Status.default_convert(value, status.uniq)
          write_attribute(attr, s.state)
          s
        end
      end 

      # composed_of field,
      #       :class_name => 'Status',
      #       :mapping => [field, "state"],
      #       :constructor => Proc.new { |i| Status.new(i, status)},
      #       :converter => Proc.new { |state| Status.default_convert(state, status) }


    end
  end
end