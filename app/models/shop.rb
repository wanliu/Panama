require 'orm_fs'

class Shop
  include Mongoid::Document
  has_many :contents, dependent: :delete do 
    def lookup(name)
      where(:name => name).first
    end
  end

  field :name, type: String

  before_create :create_shop
  after_create :initial_shop_data
  before_destroy :delete_shop

  has_one :category

  validates :name, presence: true
  validates :name, uniqueness: true

  def fs
    "/_shops/#{self.name}".to_dir
  end

  private 
  def create_shop
    copy_standardization_files

    load_default_contents

    write_default_options
  end

  def initial_shop_data
    @category = create_category(:name => name + "_" + "root") unless category
    @category.load_default
  end

  def delete_shop
    remove_standardization_files

  end

  def load_default_contents

    _config = YAML.load(fs['config/contents.yml'].read)
    contents_config = _config['contents']
    contents_config.each do |content|
      self.contents << Content.create(content)
    end
  end

  def copy_standardization_files
    base = default_shop_path
    shop_path_pattern = File.join(base, "**/*")

    root = create_vfs_workspace

    Dir[shop_path_pattern].each do |path|
      unless File.directory?(path)
        file = path.to_s.sub base + '/', ''
        copy_local_to_vfs file, root
      end
    end
  end

  def remove_standardization_files
    fs['**/*'].each do |path|
      path.destroy
    end
  end

  def default_shop_path
    Rails.application.config.default_shop_path.to_s
  end

  # 创新 商店的 虚拟文件系统
  def create_vfs_workspace
    fs
  end

  def write_default_options
  end

  def copy_local_to_vfs file, root
    path = File.join default_shop_path, file
    File.open(path, 'r') do |f|
      puts file
      root[file].write f.read 
    end
  end
end
