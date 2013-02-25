#encoding: utf-8
require 'spec_helper'

describe City, "城市地址" do

    # describe "关联检查" do  
	   #  it { should has_one(:address) } 
    # end
    
    describe "属性验证" do 
    	let(:city) { City.new } 
	    it { city.should respond_to(:name) }
    end 
end
