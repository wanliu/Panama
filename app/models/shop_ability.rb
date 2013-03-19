#商店权限
class ShopAbility
  include CanCan::Ability

  def initialize(user, shop)

    if user == shop.user
      can :manage, :all
    else
      user.groups.each do |g|
        g.permissions.each do |p|
          cls = Kernel.const_get(p.resource) rescue nil
          can p.ability, cls  if cls
        end
      end
    end
  end

end
