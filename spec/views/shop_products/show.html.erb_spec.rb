require 'spec_helper'

describe "shop_products/show" do
  before(:each) do
    @shop_product = assign(:shop_product, stub_model(ShopProduct))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
