module CommunitiesHelper

  def owner_url(owner)
    owner.is_a?(Shop) ? shop_path(owner) : person_path(owner)
  end
end
