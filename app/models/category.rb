class Category
  include Mongoid::Document
  include Mongoid::Tree

  field :name, type: String

  belongs_to :shop

  before_destroy :delete_descendants

  def load_default
    config_file = shop.fs["config/default_category.yml"].file
    config_root = YAML.load(config_file.read)["category"]

    # clear all category children
    shop.category.destroy_children
    create_node(config_root, shop.category)
    shop.category.save
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
end

Category.root = Category.create(:name => :root) unless Category.root
