# author : huxinghai
# describe : 图型显示
# example :
#    class ModelName  
#        include Graphical::Display
#
#        #定义图型属性
#        #参数 
#        #    photos: 调用属性名(必选), 
#        #    handler: 获取图片方法名(必选), 
#        #    allow: 允许显示那几项,还可以自定义图型项
#        define_graphical_attr :photos, :handler => :default_image, :allow => [:icon, :preview, :customer_img]
#
#        #可选配置
#        configrue_graphical :icon => "50x50", :preview => "200x200", :customer_img => "600x600"
#
#        def default_image
#            image
#        end
#    end
#
#    #使用
#    <%= image_tag @model.photos.icon %>
module Graphical
    module Display        
        def self.config(options = {})        
            @config ||= {
                :icon => "20x20",
                :avatar => "100x100",
                :preview => "250x187"                
            }.merge(options)            
            @config[:default] = ""
            @config
        end

        def self.included(base)
            base.extend(ClassMethods)
        end

        module ClassMethods

            #定义graphical attribute
            def define_graphical_attr(*args)
                attribute, options = args
                raise "not setting attribute argument!" if attribute.nil?
                options = { 
                    :handler => :attachment , 
                    :allow => [:icon, :avatar, :preview]
                }.merge(options || {})                                
                options[:allow].push(:default)

               self.instance_eval do
                    define_method attribute do                         
                        ImageType.new(self, options)
                    end
               end
            end

            #配置图片类型
            def configrue_graphical(options = {})
<<<<<<< HEAD
                @config ||= Graphical::Display.config.merge(options)
=======
                @config ||= Graphical::Display.config.merge(options)   
>>>>>>> chosen_add
            end
        end

        class ImageType

            attr_accessor :klass, :options

            def initialize(klass, options)
                @klass, @options  = klass, options                
                config = @klass.class.configrue_graphical
                @options[:allow].each do | type |                    
                    define_singleton_method type do 
                        @klass.send(@options[:handler]).url(config[type])
                    end
                end              
            end
        end
    end
end