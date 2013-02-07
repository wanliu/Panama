module PeopleHelper

  def active_section(name)
    content_for(:people_siderbar) do 
      name.to_s
    end
  end
end
