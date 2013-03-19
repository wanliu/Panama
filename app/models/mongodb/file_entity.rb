class Mongodb::FileEntity
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Tree
  include Mongoid::Tree::Traversal

  field :name, type: String
  field :stat, type: String
  field :size, type: Fixnum
  field :data, type: Moped::BSON::Binary
  field :path, type: String

  index({stat: 1, name: 1})

#  validates :name, presence: true
  validates :stat, presence: true

  after_rearrange :rebuild_path

  before_destroy :delete_descendants

  def create_dir(name)
    if name.blank?
      raise 'must specify a name'
    end

    begin
      dir = children.find_by(name: name, stat: 'directory')
    rescue Mongoid::Errors::DocumentNotFound
      dir = children.create(name: name, stat: 'directory')
    ensure
      dir
    end
  end

  def directory?
    self.stat == 'directory'
  end

  def file
    path = Rails.root.join("tmp/")
    if file?
      @file = Tempfile.new("vfs_" + name, path)
      @file.write(read)
      @file.rewind
      @file
    end
  end

  def file?
    self.stat == 'file'
  end

  def match(filter, &block)
    unless self.directory?
      raise 'must a directory can do match'
    end
    base = self.path.blank? ? "/" : self.path + '/'
    descendants do |n|
      path = n.path.sub base, ''
      if File.fnmatch?(filter, path, File::FNM_PATHNAME)
        block.call(n) if block
      end
    end
  end

  def mkdir(name)
    path = children.where(:name => name, :stat => "directory").first
    if path
      raise "#{name} always is existy"
    else
      children.create(:name => name, :stat => "directory")
    end
  end

  private

  def rebuild_path
    self.path = self.ancestors_and_self.collect(&:name).compact.join('/') unless name.blank?
  end
end

# FileEntity.root || begin
#   root = FileEntity.new(:stat => :directory)
#   root.save :validate => false
# end
