require 'spec_helper'

describe "people/transactions/new" do
  before(:each) do
    assign(:people_transaction, stub_model(People::Transaction).as_new_record)
  end

  it "renders new people_transaction form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => people_transactions_path, :method => "post" do
    end
  end
end
