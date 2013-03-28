class ProductPrice < ActiveRecord::Base
  has_and_belongs_to_many :property_items, :autosave => true

  alias_method :items, :property_items

  attr_accessible :price, :property_items, :items
  #
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

    items.each do |item|
      # name = item.name
      method_name = item.property.name

      define_singleton_method(method_name) do
        item.value
      end

      @delegate_properties << method_name

      define_singleton_method("#{method_name}=") do |other|

        item.value = other
      end
      _accessible_attributes[:default] << method_name

      @delegate_properties << "#{method_name}="
    end
  end

  after_find do
    delegate_property_setup
  end

  protected

  def after_category_changed
    old_val, new_val = category_id_change
    delegate_property_setup
  end

end
