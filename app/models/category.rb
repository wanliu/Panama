class Category < ActiveRecord::Base
  # include Mongoid::Tree
  # include Mongoid::Tree::Ordering
  # include Mongoid::Tree::Traversal
  #

  has_ancestry :cache_depth => true

  attr_accessible :name

  attr_accessor :indent

  mount_uploader :cover, ImageUploader

  has_many :products

  belongs_to :shop

  def load_default
    config_file = shop.fs["config/default_category.yml"].file
    config_root = YAML.load(config_file.read)["category"]

    load_category(config_root)
  end

  def load_category(config_root)
    # clear all category children
    root.descendants.destroy_all
    create_node(config_root, root)
    root.save
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

  def indent
    parent_indent = self.parent.nil? ? -1 : self.parent.indent
    parent_indent+=1
  end

  def self.root
    where(name: 'root', ancestry: nil).first
  end
end

Category.create(:name => :root) unless Category.root
