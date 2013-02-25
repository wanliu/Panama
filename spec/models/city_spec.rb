#encoding: utf-8
require 'spec_helper'

describe City, "城市地址" do

    it { have_one :address }
    
    describe "属性验证" do 
    	let(:city) { City.new }
	    it { city.should respond_to(:name) } 
    end
    
end
