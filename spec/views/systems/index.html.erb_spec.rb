require 'spec_helper'

describe "systems/index" do
  before(:each) do
    assign(:systems, [
      stub_model(System),
      stub_model(System)
    ])
  end

  it "renders a list of systems" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
