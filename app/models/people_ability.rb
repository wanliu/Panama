#encoding: utf-8
#describe: 个人权限
class PeopleAbility
    include CanCan::Ability

    def initialize(current_user, people)
      current_user ||= User.new
      if current_user == people
        can :read, Notification do |notice|          
          notice.mentionable_user_id == current_user.id
        end
        can :show_bill, People
        can :manage, User
        can :index, Notification
        can :index, Cart
        can :create, Cart
        can :destroy, Cart
        can :activity, Comment
        can :product, Comment
        can :index, OrderTransaction
        can :read, OrderTransaction do |order|
          order.buyer_id == current_user.id
        end
        can :batch_create, OrderTransaction
        can :event, OrderTransaction do |order|
          order.buyer_id = current_user.id
        end
        can :destroy, OrderTransaction do |order|
          order.buyer_id = current_user.id
        end
        can :destroy, Following do |following|
          following.user_id = current_user.id
        end
        basic_ability
      elsif current_user.persisted?   
        can :index, Cart
        can :create, Cart
        can :destroy, Cart
        basic_ability
        can :destroy, Following do |following|
          following.user_id = current_user.id
        end
      elsif current_user.new_record? == false
        basic_ability
      elsif current_user.new_record?
        cannot :manage, :all
      end
    end

    def basic_ability
      can :user, Following
      can :shop, Following
    end
end