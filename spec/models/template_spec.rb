# encoding: utf-8
require 'spec_helper'
require 'orm_fs'

describe Template do

  Shop.slient!
  let(:fs) { '/tmp/sandbox'.to_dir }
  let(:bob) { FactoryGirl.create(:user, login: 'bob') }
  let(:pepsi) { FactoryGirl.create(:shop, user: bob) }
  let(:shop_fs) { fs[pepsi.name] }

  describe "创建模板" do

    it "通过存储系统" do
      template = Template.new('index', fs)
      template.should be_a_kind_of(Template)
    end

    it "通过商店" do
      # 废弃 Template.setup(pepsi)

      template = Template.new('index', shop_fs)
      template.should be_a_kind_of(Template)
    end
  end

  describe "属性访问" do
    it "新记录" do
      # shop_fs = fs[pepsi.name]
      template = Template.new()
      template.new_record?.should be_true
    end

    describe '存在的属性' do
      require 'orm_fs'
      let(:pepsi) { Shop.first }
      let(:pepsi_fs) { "/_shops/#{pepsi.name.underscore}".to_dir }
      let(:template) { Template.new('templates/index.html.erb', pepsi_fs) }

      it "旧记录(已经保存了)" do

        template.persisted?.should be_true
      end

      it "访问数据" do
        template.data = 'hello world'
        template.data.should == 'hello world'
      end

      it "生成 key" do
        template.to_key.should == ['index']
      end

      it "模型名" do
        Template.model_name.should == "Template"
      end

      it "查找功能" do
        temp = Template.find('templates/index.html.erb', pepsi_fs)
        temp.should == template
      end
    end
  end
end