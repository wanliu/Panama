#商店权限
class ShopAbility
  include CanCan::Ability

  def initialize(user, shop)

    if user == shop.try(:user)
      can :manage, :all
    elsif shop.find_employee(user.id)
      user.groups.each do |g|
        g.permissions.each do |p|
          cls = Kernel.const_get(p.resource) rescue nil
          can p.ability, cls  if cls
        end
      end
    end
  end

end
