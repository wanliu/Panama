# encoding: utf-8
require 'spec_helper'

describe "Shops" do
  describe "GET /shops" do
    it "不能访问(没有完全店面的选择)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      expect { get shops_path }.to raise_error(ActionController::RoutingError)
    end
  end
end
