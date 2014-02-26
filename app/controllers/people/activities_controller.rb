class People::ActivitiesController < People::BaseController
	before_filter :login_required, :person_self_required

  def my_activity
    @activities = Activity.joins(:activities_participates)
    .where('activities_participates.user_id=?', @people.id)
  end


  def likes
  	@activities = Activity.joins(:activities_likes)
  	.where("activities_likes.user_id=?", @people.id)
  end
end