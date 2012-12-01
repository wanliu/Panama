require 'spec_helper'

describe SlideCell do

  context "cell instance" do
    subject { cell(:slide) }

    it { should respond_to(:show) }
    it { should respond_to(:edit) }
  end

  context "cell rendering" do
    context "rendering show" do
      subject { render_cell(:slide, :show) }

      it { should have_selector("h1", :content => "Slide#show") }
      it { should have_selector("p", :content => "Find me in app/cells/slide/show.html") }
    end

    context "rendering edit" do
      subject { render_cell(:slide, :edit) }

      it { should have_selector("h1", :content => "Slide#edit") }
      it { should have_selector("p", :content => "Find me in app/cells/slide/edit.html") }
    end
  end

end
