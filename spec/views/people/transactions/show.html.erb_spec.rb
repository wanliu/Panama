require 'spec_helper'

describe "people/transactions/show" do
  before(:each) do
    @people_transaction = assign(:people_transaction, stub_model(People::Transaction))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
