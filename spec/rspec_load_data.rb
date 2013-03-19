#describe: 加载测试数据
require "rake"

module Rspec
    module Data
        def self.load
            load_permission
        end

        def self.load_permission
            rake = Rake::Application.new
            Rake.application = rake
            rake.init
            rake.load_rakefile
            rake["permission:load"].invoke
        end
    end
end