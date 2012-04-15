class CommentsController < ApplicationController
  respond_to :html, :json
  before_filter :require_user, :except => :index

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

  def index
    @comments = Comment

    if params[:user_id].present?
      @comments = @comments.for_user(User.find_by_display_name!(params[:user_id]))
    end

    @comments = @comments.order("id DESC").paginate(
      :page => page,
      :per_page => per_page
    )

    # TODO: I wonder if there is a way to avoid adding this extra pagination stuff
    respond_with(
      page: page,
      per_page: per_page,
      total: @comments.total_pages,
      models: @comments
    )
  end

  private
  def per_page
    10
  end
end
