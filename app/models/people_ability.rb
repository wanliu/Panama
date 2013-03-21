#encoding: utf-8
#describe: 个人权限
class PeopleAbility
    include CanCan::Ability

    def initialize(current_user, people)
        current_user ||= User.new
        if current_user == people
            can :read, Notification do |notice|
                notice.user_id == current_user.id
            end
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
        end
    end
end