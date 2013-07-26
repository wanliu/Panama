require 'spec_helper'

describe "shop_products/new" do
  before(:each) do
    assign(:shop_product, stub_model(ShopProduct).as_new_record)
  end

  it "renders new shop_product form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => shop_products_path, :method => "post" do
    end
  end
end
