require 'spec_helper'

describe "systems/edit" do
  before(:each) do
    @system = assign(:system, stub_model(System))
  end

  it "renders the edit system form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => systems_path(@system), :method => "post" do
    end
  end
end
