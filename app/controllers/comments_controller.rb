class CommentsController < ApplicationController
  respond_to :html, :json
  before_filter :require_user

  def create
    comment_params = params[:comment]

    cleaned_text = sanitize(comment_params[:body])

    unless cleaned_text.blank?
      comment_data = comment_params.merge({ :commenter => current_user })
      comment_data[:body] = cleaned_text

      @comment = Comment.create(comment_data)
    end

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
