class CommentsController < ApplicationController
  respond_to :html, :json
  before_filter :require_user

  def create
    @comment = Comment.new(params[:comment])
    @comment.commenter = current_user

    @comment.save

    respond_with(@comment) do |format|
      format.html do
        redirect_to :back
      end
      format.json { render :json => {
        :body => @comment.body,
        :commentable_id => @comment.commentable_id,
        :name => @comment.commenter.display_name,
        :time => Time.zone.now.strftime("%l:%M%P")
      }}
    end
  end
end
