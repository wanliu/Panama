require 'spec_helper'

describe "people/transactions/edit" do
  before(:each) do
    @people_transaction = assign(:people_transaction, stub_model(People::Transaction))
  end

  it "renders the edit people_transaction form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => people_transactions_path(@people_transaction), :method => "post" do
    end
  end
end
