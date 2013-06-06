class FileEntity < ActiveRecord::Base

  attr_accessible :data, :name, :path, :size, :stat

  # FIXED: acts_as_tree
  #   include Mongoid::Tree
  #   include Mongoid::Tree::Traversal

  # FIXED: add_index
  #   index({stat: 1, name: 1})

  # validates :name, presence: true
  validates :stat, presence: true

  has_ancestry

  # after_rearrange :rebuild_path

  # before_destroy :delete_descendants

  def create_dir(name)
    if name.blank?
      raise 'must specify a name'
    end

    children
      .where(name: name, stat: 'directory')
      .first_or_create(name: name, stat: 'directory')
  end

  def directory?
    self.stat == 'directory'
  end

  def create_file(name)
    if name.blank?
      raise 'must specify a name'
    end

    children
      .where(name: name, stat: 'file')
      .first_or_create(name: name, stat: 'file')
  end

  def file
    path = Rails.root.join("tmp/")
    if file?
      f = Tempfile.new("vfs_" + name, path)
      f.write(data)
      f.rewind
      f
    end
  end

  def file?
    self.stat == 'file'
  end

  def path
    file_entities = ancestors
    file_entities.shift
    _path = file_entities.map {|f| f.name }.join('/')
    _path.blank? ? '/' : _path
  end

  def full_path
    File.join(path, name) unless name.nil?
  end

  def match(filter, flag = File::FNM_DOTMATCH, &block)
    unless self.directory?
      raise 'must a directory can do match'
    end
    base = path
    # descendants.select do |n|
    children.select do |n|
      path = n.full_path.sub base, ''
      if File.fnmatch?(filter, path, flag)
        block.call(n) if block
        true
      end
    end
  end

  alias_method :mkdir, :create_dir

  def self.root
    first || create_root
  end

  def self.create_root
    root = FileEntity.new(:stat => :directory)
    root.save :validate => false
    root
  end
end

FileEntity.root
# FileEntity.root or begin
#   root = FileEntity.new(:stat => :directory)
#   root.save :validate => false
# end
