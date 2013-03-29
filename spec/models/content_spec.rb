# encoding: utf-8
require 'spec_helper'

describe Content do

  it { should belong_to :shop }
  it { should have_many :resources }
  it { should validate_presence_of :name }
  it { should validate_presence_of :template }

  Shop.slient!
  let(:bob) { FactoryGirl.create(:user, login: 'bob') }
  let(:pepsi) { FactoryGirl.create(:shop, user: bob) }
  let(:content) { FactoryGirl.create(:content) do |c|
      c.resources.create(attributes_for(:resource))
      c.resources.create(attributes_for(:resource))
    end
  }

  it "获取资源" do
    content.resource.should be_a_kind_of(Resource)
  end

  it "跟据名称查询" do
    content = FactoryGirl.create(:content, name: 'found_me')
    found = Content.lookup_name('found_me').last
    content.should == found
  end

end
