#encoding: utf-8
require "spec_helper"

describe CommentsController, "评论控制器" do

  let(:shop){ FactoryGirl.create(:shop, :user => FactoryGirl.create(:user)) }
  let(:yifu){ FactoryGirl.create(:yifu, :shop => shop) }
  let(:product){ FactoryGirl.create(:product,
    :shop => shop,
    :shops_category => yifu,
    :category => FactoryGirl.create(:category)
  )}
  let(:activity){ FactoryGirl.create(:activity) }

  def person_params
    { :person_id => current_user.login  }
  end

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


  describe "GET index " do

    it "活动所有评论" do
      comment = Comment.activity(activity_params)
      get :index, person_params.merge({
        :targeable_id => activity.id,
        :targeable_type => "Activity"}), get_session
      assigns(:comments).should eq([comment])
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

    it "商品评论" do
      expect{
          post :product, person_params.merge({:comment => product_params}), get_session
        }.to change(Comment, :count).by(1)
    end

    it "评论类型" do
      post :product, person_params.merge({:comment => product_params}), get_session
      assigns(:comment).targeable_type.should eq("Product")
    end

    it "评论属于商品" do
      post :product, person_params.merge({:comment => product_params}), get_session
      assigns(:comment).targeable.should be_an_instance_of(Product)
    end

  end
end
