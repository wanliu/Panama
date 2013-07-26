require 'spec_helper'

describe "shop_products/edit" do
  before(:each) do
    @shop_product = assign(:shop_product, stub_model(ShopProduct))
  end

  it "renders the edit shop_product form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => shop_products_path(@shop_product), :method => "post" do
    end
  end
end
