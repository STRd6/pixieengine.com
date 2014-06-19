class ActivitiesController < ApplicationController
  before_filter :require_user

  def index
    @activities = current_user.activity_updates

    @friends_activity = current_user.friends_activity
  end
end
