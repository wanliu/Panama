class People::CommunitiesController < People::BaseController

  def index
    @circles = @people.circles
  end

  def people
  end
end