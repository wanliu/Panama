#encoding: utf-8
require "spec_helper"

describe People::CommentsController, "评论控制器" do

    let(:shop){ FactoryGirl.create(:shop, :user => FactoryGirl.create(:user)) }
    let(:yifu){ FactoryGirl.create(:yifu, :shop => shop) }
    let(:product){ FactoryGirl.create(:product, :shop => shop, :category => yifu) }
    let(:activity){ FactoryGirl.create(:activity) }

    def person_params
        {
          :person_id => current_user.login
        }
    end

    def product_params
        {
            :content => "这产品很好，实用...",
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


    describe "GET index " do

        it "活动所有评论" do
            comment = Comment.activity(activity_params)
            get :index, person_params.merge({:targeable_type => "Activity"}), get_session
            assigns(:comments).should eq([comment])
        end

        it "产品所有评论" do
            comment = Comment.product(product_params)
            get :index, person_params.merge({:targeable_type => "Product"}), get_session
            assigns(:comments).should eq([comment])
        end
    end

    describe "GET show" do

        it "显示一条评论" do
            comment = Comment.product(product_params)
            get :show, person_params.merge({:id => comment.id}), get_session
            assigns(:comment).should eq(comment)
        end
    end

    describe "GET new" do

        it "显示提交评论页面" do
            get :new, person_params, get_session
            assigns(:comment).new_record?.should be_true
        end
    end

    describe "POST activity" do

        it "活动评论" do
            expect{
                post :activity, person_params.merge({:comment => activity_params}), get_session
                }.to change(Comment, :count).by(1)
        end

        it "评论类型" do
            post :activity, person_params.merge({:comment => activity_params}), get_session
            assigns(:comment).targeable_type.should eq("Activity")
        end

        it "评论属于活动" do
            post :activity, person_params.merge({:comment => activity_params}), get_session
            assigns(:comment).targeable.should be_an_instance_of(Activity)
        end
    end

    describe "POST product" do

        it "产品评论" do
            expect{
                post :product, person_params.merge({:comment => product_params}), get_session
                }.to change(Comment, :count).by(1)
        end

        it "评论类型" do
            post :product, person_params.merge({:comment => product_params}), get_session
            assigns(:comment).targeable_type.should eq("Product")
        end

        it "评论属于产品" do
            post :product, person_params.merge({:comment => product_params}), get_session
            assigns(:comment).targeable.should be_an_instance_of(Product)
        end
    end
end