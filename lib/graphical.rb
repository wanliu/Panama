module Graphical
    module Display
        def self.config(options = {})        
            @config ||= {
                :icon => "20x20",
                :avatar => "100x100",
                :preview => "400x400"                
            }.merge(options)            
            @config[:default] = ""
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
                @config ||= Graphical::Display.config.merge(options)                
            end
        end

        class ImageType

            def initialize(klass, options)                                            
                config = klass.class.configrue_graphical
                options[:allow].each do | type |                    
                    define_singleton_method type do 
                        klass.send(options[:handler]).url(config[type])
                    end
                end              
            end

        end
    end
end