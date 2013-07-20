require 'spec_helper'

describe "shop_products/index" do
  before(:each) do
    assign(:shop_products, [
      stub_model(ShopProduct),
      stub_model(ShopProduct)
    ])
  end

  it "renders a list of shop_products" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
