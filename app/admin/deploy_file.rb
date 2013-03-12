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
      li "没有可用条件" 
    end
  end

  action_item do
    link_to "重置", "/system/vfs"
  end

  content do
    @root = '/'.to_dir 
    render "index", :root => @root['/_shops']['*']
  end
end


ActiveAdmin.register_page "vfs_file" do
  # menu :label => "My Menu Item Label", :parent => "Dashboard"

  sidebar :所有条件 do
    ul do
      li "没有可用条件" 
    end
  end

  action_item do
    link_to "重置", "/system/vfs"
  end

  content do
    debugger
    render "index"
  end
end