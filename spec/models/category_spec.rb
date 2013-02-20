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

      node1 = test.children[0]
      node1.should be_a_kind_of(Category)
      node1.name.should match 'node1'
      node1.should have_at_most(3).children

      node2 = node1.children[0]
      node3 = node1.children[1]
      node4 = node1.children[2]

      node2.name.should match 'node2'
      node3.name.should match 'node3'

      node4.name.should match 'node4'
      node4.should have_at_most(2).children

      node5 = node4.children[0]
      node6 = node4.children[1]

      node5.name.should match 'node5'
      node6.name.should match 'node6'
    end

    it "节点文件 `load_file`" do
    end

  end
end
