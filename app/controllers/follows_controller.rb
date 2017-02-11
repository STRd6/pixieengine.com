class FollowsController < ApplicationController
  before_action :require_user

  def create
    user = User.find(params[:id])
    follow = @current_user.follow(user)

    redirect_to user
  end

  def destroy
    user = User.find(params[:id])
    follow = Follow.find_by_follower_id_and_followee_id(@current_user.id, user.id)
    follow.destroy

    redirect_to user
  end
end
