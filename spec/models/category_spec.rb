# encoding: utf-8
require 'spec_helper'
require 'rake'

def rake
  rake = Rake::Application.new
  Rake.application = rake
  rake.init
    rake.load_rakefile
  rake
end

describe Category do

  context "db:seed" do
    hash_condition = { name: '_products_root', ancestry: nil }
    let(:root) { Category
                   .where(hash_condition)
                   .first_or_create(hash_condition) }

    before(:each) do
      Category.destroy_all
    end

    it "#root" do
      Category.root.should be_nil
    end

    it "run load category task" do
      rake['db:seed'].invoke
      root.should be_a_kind_of(Category)
      root.should have_at_most(100).children
    end
  end

  context "载入数据" do
    let(:test) { Category.create(name: 'test_root') }

    before do
    end

    after do
    end

    it "节点配置 `load_category`" do
      test.load_category([
        'name' => 'node1',
        'children' => [
          { 'name' => 'node2' },
          { 'name' => 'node3' },
          { 'name' => 'node4',
            'children' => [
              { 'name' => 'node5' },
              { 'name' => 'node6' }
            ]
          }
        ]
      ])

      puts test.descendants.size
    end

  end
end
