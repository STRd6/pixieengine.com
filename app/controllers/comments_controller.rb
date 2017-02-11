class CommentsController < ApplicationController
  before_action :require_user,
    :only => :create

  def create
    @comment = Comment.new(comment_params)

    @comment.save!

    redirect_to @comment.commentable
  end

  private
  def comment_params
    params[:comment].permit([:body, :commentable_id, :commentable_type]).merge(:commenter => current_user)
  end
end
