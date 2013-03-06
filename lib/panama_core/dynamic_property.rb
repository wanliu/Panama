# encoding: utf-8
module PanamaCore
  module DynamicProperty
    extend ActiveSupport::Concern

    included do |klass|
      # 设置更换 category 时,会自动更换属性
      define_callbacks :category_attribute_changed
      set_callback :category_attribute_changed, :after, :after_category_changed

      has_and_belongs_to_many :properties do
        def [](name)
          select { |property| property.name == name.to_s }.first
        end
      end

      has_many :properties_values,
               :class_name => "ProductPropertyValue",
               :autosave => true do
        def [](property_name)
          property = @association.owner.properties[property_name]
          select { |pv| pv.property.id == property.id }.first
        end
      end

      after_find do
        delegate_property_setup
      end
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

    def attach_properties!
      unless category.nil?
        properties.clear if properties.size > 0
        category.properties.each do |property|
          properties << property
        end
        delegate_property_setup
        # save
      end
    end

    protected

    def after_category_changed
      old_val, new_val = category_id_change
      delegate_property_setup
    end

    def delegate_property_setup
      @delegate_properties ||= []

      @delegate_properties.each do |method_name|
        @@_delete_method_name = method_name.to_sym
        class << self
          remove_method @@_delete_method_name
        end
      end

      @delegate_properties = []

      properties.each do |property|
        name = property.name
        method_name = name

        define_singleton_method(method_name) do
          pv = product_property_values(name)
          pv.value unless pv.nil?
        end
        @delegate_properties << method_name

        define_singleton_method("#{method_name}=") do |other|

          factory_property name do |pv|
            pv.product_id = id
            pv.property_id = property.id
            pv.value = other
          end
        end
        @delegate_properties << "#{method_name}="
      end
    end

    def factory_property(name, &block)
      method = persisted? ? :create : :build

      pv = product_property_values(name) || properties_values.send(method)
      yield pv
    end

    def product_property_values(name)
      property = properties.select { |property| property.name == name }.first
      properties_values.select { |pv| pv.property.id == property.id }.first
    end
  end
end