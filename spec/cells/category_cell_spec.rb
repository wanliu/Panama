require 'spec_helper'

describe CategoryCell do

  context "cell instance" do
    subject { cell(:category) }

    it { should respond_to(:show) }
    it { should respond_to(:edit) }
  end

  context "cell rendering" do
    context "rendering show" do
      subject { render_cell(:category, :show) }

      it { should have_selector("h1", :content => "Category#show") }
      it { should have_selector("p", :content => "Find me in app/cells/category/show.html") }
    end

    context "rendering edit" do
      subject { render_cell(:category, :edit) }

      it { should have_selector("h1", :content => "Category#edit") }
      it { should have_selector("p", :content => "Find me in app/cells/category/edit.html") }
    end
  end

end
