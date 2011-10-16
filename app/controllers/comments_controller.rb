class CommentsController < ApplicationController
  respond_to :html, :json
  before_filter :require_user

  def create
    comment_params = params[:comment]

    cleaned_text = Sanitize.clean(comment_params[:body], :elements => ['a', 'img', 'em', 'strong', 'pre', 'code', 'hr', 'ul', 'li', 'ol', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'u', 'p'],
      :attributes => {
        'a' => ['href', 'title'],
        'img' => ['src']
      },
      :protocols => {
        'a' => {'href' => ['http', 'https', 'mailto']},
        'img' => {'src' => ['http', 'data']}
      }
    )

    unless cleaned_text.blank?
      @comment = Comment.create({ :commentable_type => comment_params[:commentable_type], :commentable_id => comment_params[:commentable_id], :body => cleaned_text, :commenter => current_user })
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
