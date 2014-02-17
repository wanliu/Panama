# encoding: utf-8
require File.expand_path('../synchronous_property', __FILE__)

module PanamaCore
  module DynamicProperty
    extend ActiveSupport::Concern

    included do |klass|

      # 设置更换 category 时,会自动更换属性
      define_callbacks :category_attribute_changed
      set_callback :category_attribute_changed, :after, :after_category_changed

      cattr_accessor :dynamic_configuration
      cattr_accessor :quickly_status
      @@quickly_status = false

      @@dynamic_configuration = default_dynamic_configuration

      after_initialize :setup_dynamic_properties

      after_find do
        delegate_property_setup
      end
    end

    module ClassMethods

      def property_options(relation_name, options)
        dynamic_configuration[:properties_relation] = relation_name
      end

      def value_options(relation_name, options)
        dynamic_configuration[:values_relation] = relation_name
      end

      def items_options(relation_name, options)
        dynamic_configuration[:property_items_relation] = relation_name
      end

      def dynamic_property_read_method(conditions, &block)
        dynamic_configuration[:property_read_methods] = ConditionBlock.new(conditions, &block)
      end

      def dynamic_property_write_method(conditions, &block)
        dynamic_configuration[:property_write_methods] = ConditionBlock.new(conditions, &block)
      end

      def default_dynamic_configuration
        {
          :properties_relation      => :properties,
          :values_relation          => :properties_values,
          :property_items_relation  => :property_items
        }.dup
      end

      def create_properties_relation
        has_and_belongs_to_many default_dynamic_configuration[:properties_relation]
      end

      def create_values_relation
        has_many default_dynamic_configuration[:values_relation]
      end

      def create_items_relation
        has_and_belongs_to_many default_dynamic_configuration[:property_items_relation]
      end

    end

    def setup_dynamic_properties
      _p_relation = dynamic_configuration[:properties_relation]
      callback_fullname = "after_add_for_#{_p_relation}"
      callback_methods = self.class.send(callback_fullname)
      callback_methods << :add_property unless callback_methods.include?(:add_property)
    end

    def write_attribute(attr_name, value)
      super
      if attr_name == 'category_id'
        @last_changed_attr = attr_name
        run_callbacks(:category_attribute_changed)
      end
    end

    def property_methods
      @delegate_properties ||= []
    end

    def delegate_property_setup
      @delegate_properties ||= []
      @delegate_properties.each do |method_name|
        @@_delete_method_name = method_name.to_sym
        class << self
          remove_method @@_delete_method_name

        end
        # 删除之前的 安全 attributes
        _accessible_attributes[:default].delete(method_name)
      end

      @delegate_properties = []

      relation_properties.each do |property|
        name = property.name
        method_name = name

        define_singleton_method(method_name) do
          pv = product_property_values(name)
          pv.value unless pv.nil?
        end

        @delegate_properties << method_name

        define_singleton_method("#{method_name}=") do |other|
          factory_property name, :valuable => self do |pv|
            pv.property_id = property.id
            pv.value = other
          end
        end
        _accessible_attributes[:default] << method_name

        @delegate_properties << "#{method_name}="
      end
    end

    protected

    def after_category_changed
      old_val, new_val = category_id_change
      delegate_property_setup
    end

    def factory_property(name, options = {}, &block)
      method = persisted? ? :create : :build
      pv = product_property_values(name) || relation_values.send(method, options, &block)
      yield pv
    end

    def product_property_values(name)
      property = relation_properties.select { |property| property.name == name }.first
      relation_values.select { |pv| pv.property_id == property.id }.first unless property.nil?
    end

    def relation_properties
      send dynamic_configuration[:properties_relation]
    end

    def relation_values
      send dynamic_configuration[:values_relation]
    end

    def relation_items
      send dynamic_configuration[:property_items_relation]
    end

    def add_property(property)
      property.items.each do |item|
        relation_items << item
      end
      # relation_properties << property
    end

    def remove_property(property)

    end

    def replace_relations(relation)
      original = relation.reset
      deleteions = original - relation
      relation.delete(deleteions)
      additionas = relation - original
      additionas.each do |prop|
        relation << prop
      end
    end
  end
end