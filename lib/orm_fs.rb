module VPS
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

        unless file_entity && file_entity.stat
          raise("#{path} must a file")
        end

        handle = StringIO.new(file_entity.data)
        while buff = handle.gets(self.buffer)
          block.call buff
        end
      end

      def write_file(original_path, append, &block)
        file_entity = parse_path path
        unless file_entity && file_entity.stat
          raise("#{original_path} must a file")
        end
        handle = StringIO.new(file_entity.data)
        block.call(Write.new(handle))
      end

      def delete_file path
        file_entity = parse_path path
        unless file_entity && file_entity.stat == 'file'
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
          root
        else
          paths = path.split('/')
          file_entity = paths.inject(root) do |parent, path| 
            begin
              parent.children.find_by(:name => path, :stat => 'directory')
            rescue Mongoid::Errors::DocumentNotFound
              parent.children.create_dir(path)
              retry
            end
          end
        end
      end

      def delete_dir original_path
        path = with_root original_path
        ::FileUtils.rm_r path
      end

      def each_entry path, query, &block
        path = with_root path

        if query
          path_with_trailing_slash = path == '/' ? path : "#{path}/"
          ::Dir["#{path_with_trailing_slash}#{query}"].each do |absolute_path|
            name = absolute_path.sub path_with_trailing_slash, ''
            block.call name, ->{::File.directory?(absolute_path) ? :dir : :file}
            # if ::File.directory? absolute_path
            #   block.call relative_path, :dir
            # else
            #   block.call relative_path, :file
            # end
          end
        else
          ::Dir.foreach path do |name|
            next if name == '.' or name == '..'
            block.call name, ->{::File.directory?("#{path}/#{name}") ? :dir : :file}
            # if ::File.directory? "#{path}/#{relative_name}"
            #   block.call relative_name, :dir
            # else
            #   block.call relative_name, :file
            # end
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
            begin
              file_entity = paths.inject(root) do |parent, path| 
                parent.children.find_by(:name => path)
              end
            rescue Mongoid::Errors::DocumentNotFound
              nil
            ensure
              file_entity
            end
          end
        end
    end
  end
end