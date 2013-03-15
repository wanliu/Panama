class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_group?
      can :manage, :all
    else
      can :read, Comment
      can :create, Comment
      can :update, Comment
      can :destroy, Comment
    end

  end

end
