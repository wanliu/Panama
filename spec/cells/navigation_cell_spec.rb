require 'spec_helper'

describe NavigationCell do

  context "cell instance" do
    subject { cell(:navigation) }

    it { should respond_to(:show) }
    it { should respond_to(:edit) }
  end

  context "cell rendering" do
    context "rendering show" do
      subject { render_cell(:navigation, :show) }

      it { should have_selector("h1", :content => "Navigation#show") }
      it { should have_selector("p", :content => "Find me in app/cells/navigation/show.html") }
    end

    context "rendering edit" do
      subject { render_cell(:navigation, :edit) }

      it { should have_selector("h1", :content => "Navigation#edit") }
      it { should have_selector("p", :content => "Find me in app/cells/navigation/edit.html") }
    end
  end

end
