class VfsController < ApplicationController
	def expansion  
		root = '/'.to_dir
		json_obj = z_json root["#{params[:p]}"]['*'], params[:file_path]
		render :json => json_obj
	end
  
	def z_json(root, file_path)  
		obj_a = {p: file_path}
		obj_a[:n] = []
		root.each do |r|
			obj_a[:n] << {
				name: r.name
			}
		end
		obj_a 	
	end

	def edit_file
		original = params[:file_path]
		file_load = FileLoad.new(original)
		file_name = params[:app_file]["name"]
		file_load.data = params[:app_file]["data"]
		@new_file = params[:app_file]
		if file_name != params[:file_name]
			@new_file = edit_name(original, file_name)
		end
		redirect_to "/system/vfs_file?file_path=#{params[:file_path]}"
	end

	def  edit_name(original, file_name)
		last_index = original.rindex('/')
    	paths  = original[0...last_index] 
    	root = '/'.to_dir
		file_obj = root[original]
		new_file = root["#{paths}/#{file_name}"]
		new_file.write file_obj.read
		file_obj.destroy
		new_file
	end

	def destroy_file
		root = '/'.to_dir
		file_obj = root[params["p"]].destroy
		render :json => {}
	end

	def create_file 
		root = '/'.to_dir
		file_obj = root[params[:app_file]["name"]]
		file_obj.write params[:app_file]["data"]
		redirect_to "/system/vfs"

	end
end