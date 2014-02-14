# encoding: utf-8
module PanamaCore
  module SynchronousProperty
    extend ActiveSupport::Concern

    included do |klass|
      define_callbacks :attach_properties
      set_callback :attach_properties, :after, :after_attach_properties_callback

      cattr_accessor :attach_properties_procs
      @@attach_properties_procs = []

      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def self.after_attach_properties(name = nil, &block)
          @@attach_properties_procs ||= []
          if name.nil? && block_given?
            @@attach_properties_procs << block
          elsif name.present?
            @@attach_properties_procs << proc { send name }
          end
        end
      RUBY

      before_save do
        replace_relations relation_properties
        replace_relations relation_values
        replace_relations relation_items
      end
    end

    # module ClassMethods

    #   def after_attach_properties(name = nil, &block)
    #     attach_properties_procs ||= []
    #     debugger
    #     if name.nil? && block_given?
    #       attach_properties_procs << block
    #     elsif name.present?
    #       attach_properties_procs << proc { send name }
    #     end
    #   end
    # end


    def attach_properties!
      unless category.nil?
        relation_properties.delete_if { true } if relation_properties.size > 0
        # relation_values.delete_if { true } if relation_values.size > 0
        relation_items.delete_if { true } if relation_items.size > 0

        category.properties.each do |prop|

          relation_properties.target << prop
          # properties.target << property
          relation_items.target.concat prop.items
        end

        run_callbacks :attach_properties

        delegate_property_setup
        # save
      end
    end

    protected

    def after_attach_properties_callback
      @@attach_properties_procs.each do |callback|
        instance_exec &callback if callback.is_a?(Proc)
      end
    end
  end
end