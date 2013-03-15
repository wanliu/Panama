require 'vfs'

module Vfs
  module Drivers
    class ORMFS
      class Writer
        def initialize out; @out = out end

        def write data
          @out.write data
        end
      end

      DEFAULT_BUFFER = 1000 * 1024

      def initialize(options = {})
        @root = options[:root] || FileEntity.root
      end

      def open &block
        block.call self if block
      end
      def close; end

      attr_writer :buffer
      def buffer
        @buffer || DEFAULT_BUFFER
      end
      #
      # Attributes
      #
      def attributes(path)
        file_entity = parse_path(path)
        unless file_entity.nil?
          attrs = {}
          attrs[:file] = file_entity.file?
          attrs[:dir]  = file_entity.directory?

          # attributes special for file system
          attrs[:created_at] = file_entity.created_at
          attrs[:updated_at] = file_entity.updated_at
          attrs[:size]       = file_entity.size if attrs[:file]
          attrs
        end
      rescue Errno::ENOTDIR
        nil
      rescue Errno::ENOENT
        nil
      end

      def set_attributes path, attrs
        # TODO2 set attributes
        not_implemented
      end

      #
      # File
      #
      def read_file(path, &block)
        file_entity = parse_path path
        unless file_entity && file_entity.file?
          raise("#{path} must a file")
        end

        handle = StringIO.new(file_entity.data || "")
        while buff = handle.gets(self.buffer)
          block.call buff
        end
      end

      def write_file(original, append, &block)
        last_index = original.rindex('/')
        paths, last_name = original[0...last_index], original[(last_index+1)..-1]

        file_entity = retrieve_path paths
        unless file_entity && file_entity.directory?
          raise("#{original_path} must a directory")
        end

        fe = file_entity.children.where(name: last_name, stat: 'file').first
        unless fe
          fe = file_entity.children.create(name: last_name, stat: 'file')
        end

        handle = StringIO.new
        block.call(Writer.new(handle))
        handle.close
        fe.data = handle.string
        fe.save
      end

      def delete_file path
        file_entity = parse_path path
        unless file_entity && file_entity.file?
          raise('must file type')
        end

        file_entity.destroy
      end

      # def move_file from, to
      #   FileUtils.mv from, to
      # end


      #
      # Dir
      #
      def create_dir path
        if path == '/'
          raise('root always existy')
        else
          paths = path.split('/')
          file_entity = paths.inject(root) do |parent, path|
            begin
              parent.children.where(:name => path, :stat => 'directory').first
            rescue Mongoid::Errors::DocumentNotFound
              parent.create_dir(path)
              retry
            end
          end
        end
      end

      def delete_dir original_path
        path = parse_path original_path
        if path && path.directory?
          path.destroy
        end
      end

      def each_entry path, query, &block
        current_path = parse_path path
        base = path.blank? ? '/' : path
        if current_path && current_path.directory?
          if query
            current_path.match query do |f|
              block.call f.name, ->{f.directory? ? :dir : :file}
            end
          else
            current_path.descendants do |f|
              block.call f.name, ->{f.directory? ? :dir : :file}
            end
          end
        end
      end

      protected
        def root
          @root || raise('root not defined!')
        end

        def parse_path(path)
          if path == '/'
            root
          else
            paths = path.split('/')
            paths.shift if paths.first.blank?
            file_entity = paths.inject(root) do |parent, path|
              parent.children.where(:name => path).first unless parent.nil?
            end
          end
        end

        def retrieve_path(path)
          if path == '/' or path == ''
            root
          else
            paths = path.split('/')
            paths.shift if paths.first.blank?
            begin
              file_entity = paths.inject(root) do |parent, path|
                pa = parent.children.where(:name => path, :stat => 'directory').first
                unless pa
                  pa = parent.children.create(:name => path, :stat => 'directory')
                end
                pa
              end

              file_entity
            end
          end
        end
    end
  end
end

module Vfs
  class << self
    def default_driver
      ::Vfs::Drivers::ORMFS.new
    end
  end
end