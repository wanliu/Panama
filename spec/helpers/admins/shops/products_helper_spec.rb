require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the Admins::Shops::ProductsHelper. For example:
#
# describe Admins::Shops::ProductsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe Admins::Shops::ProductsHelper do
  # let(:helper) { Admins::Shops::ProductsHelper.new }

  describe "render_styles method and it's sub methods" do

    describe "render_styles" do
      it 'invoke the sub_product_property method' do
        should_receive(:render_style).exactly(5).times
        render_styles((1..5).to_a)
      end
    end

    describe "render_style" do
      let(:group) { double("style_group") }
      let(:items) { (1..4).to_a }

      def mock_style(name, is_colour_model = false)
        group.stub(:items).and_return(items)
        group.stub(:name).and_return(name)
        css_class = name.downcase
        should_receive(:sub_product_property).with(name,
                                                   items,
                                                   { class: css_class },
                                                   :title,
                                                   is_colour_model).exactly(1).times
        render_style(group)
      end

      it "invoke the sub_product_property method without color model" do
        mock_style('good_name')
      end

      it "invoke the sub_product_property method with color model" do
        mock_style('colours', true)
      end
    end

    describe "sub_product_property" do
      it "should invoke 3 methods" do
        values = (1..5).to_a
        should_receive(:append_content).exactly(5).times

        sub_product_property('sizes', values, { :class => 'css_class' }, :to_s, false)
      end

      # TODO 重构append_content
    end

  end

end