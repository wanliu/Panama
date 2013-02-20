#author: huxinghai
#describe: 图型化测试

require 'spec_helper'

describe Graphical do

    PHOTO_URL = "/attachment/file/29345.png"
    ALLOW_TYPE = [:icon, :preview, :customer_type]
    PHOTO_SIZE = {:icon => "50x50", :preview => "200x200", :customer_type => "600x600"}

    class PhotoUploader
        def url(version_name = nil)
            "#{PHOTO_URL}!#{version_name}"
        end
    end

    class ModelName
        attr_accessor :file
        include Graphical::Display       

        def initialize(file)
            @file = file
        end

        define_graphical_attr :photos, :handler => :default_image, :allow => ALLOW_TYPE

        def default_image
            file
        end

        configrue_graphical PHOTO_SIZE
    end

    subject do 
        ModelName.new(PhotoUploader.new)
    end 
    
    before :each do 
        @config = {
            :header => "100x100",
            :icon => "50x50",
            :preview => "500x500",
            :avatar => "60x60"
        }
    end

    it "default config graphical type" do
        config = Graphical::Display.config
        config.is_a?(Hash).should be_true
    end

    it "global config graphical type" do 
        config = Graphical::Display.config @config        
        config.should eq(@config.merge(:default => ""))
    end

    it "attribute class" do 
        subject.photos.is_a?(Graphical::Display::ImageType).should be_true        
    end

    it "allow photo type and size" do 
        ALLOW_TYPE.select{|t| subject.photos.send(t).should eq("#{PHOTO_URL}!#{PHOTO_SIZE[t]}") } 
    end
end