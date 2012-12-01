require 'spec_helper'

describe TopbarCell do

  context "cell instance" do
    subject { cell(:topbar) }

    it { should respond_to(:show) }
    it { should respond_to(:edit) }
  end

  context "cell rendering" do
    context "rendering show" do
      subject { render_cell(:topbar, :show) }

      it { should have_selector("h1", :content => "Topbar#show") }
      it { should have_selector("p", :content => "Find me in app/cells/topbar/show.html") }
    end

    context "rendering edit" do
      subject { render_cell(:topbar, :edit) }

      it { should have_selector("h1", :content => "Topbar#edit") }
      it { should have_selector("p", :content => "Find me in app/cells/topbar/edit.html") }
    end
  end

end
