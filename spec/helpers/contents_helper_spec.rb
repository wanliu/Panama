require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the ContentsHelper. For example:
#
# describe ContentsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe ContentsHelper do

  it "render_content_ex" do
    @content = Content.create(:name => 'test', :template => '/templates')
     # helper.render_content_ex()
  end
end
