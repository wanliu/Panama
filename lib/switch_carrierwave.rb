# author: huxinghai
# describe: 切换上传服务器

module Carrierwave
    module Switch   
        class << self
            def configure(&block)               
                config = YAML::load_file("#{Rails.root}/config/switch_carrierwave.yml")                
                storage = (config["upload_storage"] || "file").to_sym
                CarrierWave.configure{| config | config.storage = storage }
                yield(storage) if block_given?
            end 
        end
    end
end

Carrierwave::Switch.configure do | storage |        
    if storage == :file
        ImageUploader.class_eval do        
            include CarrierWave::MiniMagick         
            def url(version_name = "")                    
                args = {}
                args = "t#{version_name.split("x").join}".to_sym unless version_name.blank?
                url = super(args)  

                file_path = "#{ImageUploader.root.call}#{url}"
                unless File.exist?(file_path)           
                    return (version_name.blank? ? default_url : "#{default_url}!#{version_name}")
                end

                return url if version_name.blank? 
                url            
            end

            CarrierWave::Uploader.version_names.each do | vname |            
                xy = vname.split("x")
                return if xy.length <= 0            
                xy.push(xy[0]) if xy.length <= 1                                                

                version "t#{vname.split("x").join}".to_sym do                
                    process :resize_to_fill => xy.map{ | x | x.to_i }
                end
            end        
        end
    end
end