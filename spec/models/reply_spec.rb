#encoding: utf-8
require 'spec_helper'

describe Reply, "评论回复模型" do

  it{ should belong_to(:comment) }
  it{ should belong_to(:user) }

end
