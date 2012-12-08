require 'spec_helper'

describe NewsletterCell do

  context "cell instance" do
    subject { cell(:newsletter) }

    it { should respond_to(:form) }
  end

  context "cell rendering" do
    context "rendering form" do
      subject { render_cell(:newsletter, :form) }

      it { should have_selector("h1", :content => "Newsletter#form") }
      it { should have_selector("p", :content => "Find me in app/cells/newsletter/form.html") }
    end
  end

end
