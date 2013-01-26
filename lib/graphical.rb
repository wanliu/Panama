module Graphical
    module Display
        def self.config(options = {})
            @config ||= {
                :ico => "20x20",
                :avatar => "100x100",
                :img => ""
            }.merge(options)
        end

        def self.included(base)
            base.extend(ClassMethods)
        end

        module ClassMethods

            def define_graphical_attr(*args)
                attribute, options = args
                raise "not setting attribute argument!" if attribute.nil?
                options = { 
                    :handler => :attachment , 
                    :allow => [:ico, :avatar, :img]
                }.merge(options || {})               

               self.instance_eval do
                    define_method attribute do                         
                        ImageType.new(self, options)
                    end
               end
            end

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