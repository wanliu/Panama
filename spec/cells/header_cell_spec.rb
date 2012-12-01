require 'spec_helper'

describe HeaderCell do

  context "cell instance" do
    subject { cell(:header) }

    it { should respond_to(:show) }
    it { should respond_to(:edit) }
  end

  context "cell rendering" do
    context "rendering show" do
      subject { render_cell(:header, :show) }

      it { should have_selector("h1", :content => "Header#show") }
      it { should have_selector("p", :content => "Find me in app/cells/header/show.html") }
    end

    context "rendering edit" do
      subject { render_cell(:header, :edit) }

      it { should have_selector("h1", :content => "Header#edit") }
      it { should have_selector("p", :content => "Find me in app/cells/header/edit.html") }
    end
  end

end
