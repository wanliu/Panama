require 'orm_fs'
module PanamaCore
  module VFS
    extend self

    def base_path
      Rails.root.join("app/_panama_files").to_s
    end

    def load_panama_files
      path_pattern = File.join(base_path, "**/*")

      Dir[path_pattern].each do |path|
        unless File.directory?(path)
          file = path.to_s.sub base_path + '/', ''
          copy_local_to_vfs file, root
        end
      end
    end

    def root
      '/panama'.to_dir
    end

    def copy_local_to_vfs file, root
      path = File.join base_path, file
      File.open(path, 'r') do |f|
        root[file].write f.read
      end
    end

    def clear_panama_files
      root.destroy
    end
  end
end