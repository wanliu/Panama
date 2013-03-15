class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_group?(:admin)
      can :manage, :all
    elsif user.has_group?(:sale)

      can :read, OrderTransaction
      can :create, OrderTransaction
    elsif user.has_group?(:inventory)

      can :read, OrderTransaction
      can :update, OrderTransaction
    end

  end

end
