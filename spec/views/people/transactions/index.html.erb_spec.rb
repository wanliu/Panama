require 'spec_helper'

describe "people/transactions/index" do
  before(:each) do
    assign(:people_transactions, [
      stub_model(People::Transaction),
      stub_model(People::Transaction)
    ])
  end

  it "renders a list of people/transactions" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
