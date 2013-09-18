#encoding: utf-8
require 'spec_helper'

describe Comment,"评论模型" do

    let(:shop){ FactoryGirl.create(:shop, :user => FactoryGirl.create(:user)) }
    let(:yifu){ FactoryGirl.create(:yifu, :shop => shop) }
    let(:category){ FactoryGirl.create(:category) }
    let(:product){ FactoryGirl.create(:product,
        :shop => shop,
        :shops_category => yifu,
        :category => category) }

    let(:activity){ FactoryGirl.create(:activity, :product => product, :author => anonymous) }

    it{ should belong_to :user }
    it{ should belong_to :targeable }
    it{ should have_many :replies }

    #验证
    it{ should validate_presence_of :content }

    def product_params
        {
            :content => "这商品很好，实用...",
            :user_id => anonymous.id,
            :targeable_id => product.id,
            :targeable_type => "Product"
        }
    end

    def activity_params
        {
            :content => "这活动折扣很多...",
            :user_id => anonymous.id,
            :targeable_id => activity.id,
            :targeable_type => "Activity"
        }
    end


    it "验证属性" do
        comment = Comment.new
        comment.should respond_to(:content)
        comment.should respond_to(:user)
        comment.should respond_to(:targeable)
    end

    it "验证" do
        comment = Comment.new(product_params)
        comment.valid?.should be_false

        comment.targeable_type = :Product
        comment.valid?.should be_true

        comment.content = nil
        comment.valid?.should be_false

        comment.content = "很好"
        comment.valid?.should be_true

        comment.targeable_id = 0
        comment.valid?.should be_false

        comment.targeable_id = product.id
        comment.valid?.should be_true

        comment.user_id = 0
        comment.valid?.should be_false

        comment.user_id = anonymous.id
        comment.valid?.should be_true
    end

    describe "活动评论" do

        it "调用" do
            expect{
                Comment.activity(activity_params)
                }.to change(Comment, :count).by(1)
        end

        it "类型" do
            comment = Comment.activity(activity_params)
            comment.targeable_type.should eq(activity.class.name)
        end

        it "应该属于活动" do
            comment = Comment.activity(activity_params)
            comment.targeable.should be_an_instance_of(Activity)
        end
    end

    describe "商品评论" do

        it "调用" do
            expect{
                Comment.product(product_params)
            }.to change(Comment, :count).by(1)
        end

        it "类型" do
            comment = Comment.product(product_params)
            comment.targeable_type.should eq(product.class.name)
        end

        it "应该属于商品" do
            comment = Comment.product(product_params)
            comment.targeable.should be_an_instance_of(Product)
        end
    end
end
