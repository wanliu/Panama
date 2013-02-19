require 'spec_helper'
require 'rake'

def rake 
	rake = Rake::Application.new
	Rake.application = rake
	rake.init
    rake.load_rakefile
	rake
end

describe Category do

  describe "db:seed" do
  	before(:each) do 
  		Category.destroy_all
  	end

  	it "#root" do
	    Category.root.should be_nil
  	end

  	it "run load category task" do 
		rake['db:seed'].invoke
		Category.root.should be_a_kind_of(Category)
		Category.root.should have_at_most(100).children 
  	end
  end
end
