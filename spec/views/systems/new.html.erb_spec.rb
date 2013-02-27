require 'spec_helper'

describe "systems/new" do
  before(:each) do
    assign(:system, stub_model(System).as_new_record)
  end

  it "renders new system form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => systems_path, :method => "post" do
    end
  end
end
