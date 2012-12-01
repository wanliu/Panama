require 'spec_helper'

describe BreadcrumbsCell do

  context "cell instance" do
    subject { cell(:breadcrumbs) }

    it { should respond_to(:show) }
    it { should respond_to(:edit) }
  end

  context "cell rendering" do
    context "rendering show" do
      subject { render_cell(:breadcrumbs, :show) }

      it { should have_selector("h1", :content => "Breadcrumbs#show") }
      it { should have_selector("p", :content => "Find me in app/cells/breadcrumbs/show.html") }
    end

    context "rendering edit" do
      subject { render_cell(:breadcrumbs, :edit) }

      it { should have_selector("h1", :content => "Breadcrumbs#edit") }
      it { should have_selector("p", :content => "Find me in app/cells/breadcrumbs/edit.html") }
    end
  end

end
