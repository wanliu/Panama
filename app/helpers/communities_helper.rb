module CommunitiesHelper

  def owner_url(owner)
    owner.is_a?(Shop) ? shop_path(owner) : person_path(owner)
  end

  def access_denied?
    params[:action] == "access_denied"
  end

  def except_denied?(actions)
    actions.map(&:to_s).include?(params[:action])
  end

  def side_active_for(name)
    content_for :side_active do
      name.to_s
    end
  end
end
