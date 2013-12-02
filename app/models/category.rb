class Category < ActiveRecord::Base
  # include Mongoid::Tree
  # include Mongoid::Tree::Ordering
  # include Mongoid::Tree::Traversal
  #
  attr_accessible :name

  has_and_belongs_to_many :catalogs
  has_many    :products
  has_and_belongs_to_many :properties, :autosave => true
  has_many    :contents, :as => :contentable
  has_ancestry :cache_depth => true
  has_many    :price_options, :as => :optionable, :autosave => true

  validates :name, presence: true

  attr_accessor :indent
  mount_uploader :cover, ImageUploader

  def load_category(config_root)
    create_node(config_root, root)
    root.save
  end

  def prices_definition
    price_options.map do |po|
      po.property
    end
  end

  def find_property(property)
    property_id = property.is_a?(Property) ? property.id : property
    CategoriesProperty.find_by(:category_id => id, :property_id => property_id)
  end

  def _properties
    CategoriesProperty.where(:category_id => id)
    .includes(:category).includes(:property).includes(:values)
  end

  def filter_properties
    _properties.filters
  end

  def clear_categories
    root.descendants.destroy_all
  end

  def load_file(file)
    config_root = YAML.load_file(file)["category"]
    load_category(config_root)
  end

  def create_node(_config_parent, _tree_parent)
    _config_parent.each do |config|
      # child = Category.create(name: config["name"])
      child = _tree_parent.children.create!(name: config["name"])
      if config["children"] && config["children"].is_a?(Array)
        child.create_node(config["children"], child)
      end
    end
  end

  def descendant_of?(node)
    node.descendants.include?(self)
  end

  def indent
    parent_indent = self.parent.nil? ? -1 : self.parent.indent
    parent_indent+=1
  end

  def self.root
    hash = {name: '_products_root', ancestry: nil}
    where(hash).first_or_create(hash)
  end

  def self.last_children
    Category.joins("left join categories as c
      on concat(categories.ancestry,'/',categories.id)=c.ancestry")
    .where("c.ancestry is NULL and not categories.ancestry is NULL")
  end
end
