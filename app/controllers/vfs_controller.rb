class VfsController < ApplicationController
	def expansion  
		root = '/'.to_dir
		json_obj = z_json root["/_shops#{params[:p]}"]['*'], params[:file_path]
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

	def show_file
		debugger
	end
end