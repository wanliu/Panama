require 'spec_helper'

describe ShoppingCartCell do

  context "cell instance" do
    subject { cell(:shopping_cart) }

    it { should respond_to(:show) }
    it { should respond_to(:edit) }
  end

  context "cell rendering" do
    context "rendering show" do
      subject { render_cell(:shopping_cart, :show) }

      it { should have_selector("h1", :content => "ShoppingCart#show") }
      it { should have_selector("p", :content => "Find me in app/cells/shopping_cart/show.html") }
    end

    context "rendering edit" do
      subject { render_cell(:shopping_cart, :edit) }

      it { should have_selector("h1", :content => "ShoppingCart#edit") }
      it { should have_selector("p", :content => "Find me in app/cells/shopping_cart/edit.html") }
    end
  end

end
