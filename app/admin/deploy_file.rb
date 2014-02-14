#encoding: utf-8

# ActiveAdmin.register FileEntity, :as => 'VFS' do

#   index do
#     @root = '/'.to_dir
#     render "index", :root => @root['*']
#   end

# end

ActiveAdmin.register_page "VFS" do
  # menu :label => "My Menu Item Label", :parent => "Dashboard"

  sidebar :所有条件 do
    ul do
      li do
        input
      end
    end
  end

  action_item do
    link_to "添加文件", "/system/vfs_file_add"
  end

  content do
    @root = '/'.to_dir
    render "index", :root => @root['*']
  end
end


ActiveAdmin.register_page "vfs_file" do
  # menu :label => "My Menu Item Label", :parent => "Dashboard"
  menu false

  sidebar :所有条件 do
    ul do
      li "没有可用条件"
    end
  end

  content do
    root = '/'.to_dir
    file_obj = root[params[:file_path]]
    text = file_obj.read
    @app_file = AppFile.new
    @app_file.data = text
    @app_file.name = file_obj.name
    render "show", :file_path => params[:file_path], :new_app_file => @app_file
  end
end

ActiveAdmin.register_page "vfs_file_add" do
  # menu :label => "My Menu Item Label", :parent => "Dashboard"
  menu false

  sidebar :所有条件 do
    ul do
      li "没有可用条件"
    end
  end

  content do
    @app_file = AppFile.new
    render "new", :new_app_file => @app_file
  end
end