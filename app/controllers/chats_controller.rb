class ChatsController < ApplicationController
  respond_to :html, :json

  def create
    text = auto_link(params[:body], :sanitize => false, :html => { :target => '_blank' })

    cleaned_text = sanitize(text)

    unless cleaned_text.blank?
      Chat.create({ :user => current_user, :text => cleaned_text })
    end

    render :nothing => true
  end

  def destroy
    chat = Chat.find(params[:id])

    if chat.destroy
      respond_to do |format|
        format.json do
          render :json => { :status => "ok" }
        end
      end
    end
  end

  def recent
    respond_to do |format|
      format.json { render :json => Chat.recent.reverse }
    end
  end

  def active_users
    @active_users = User.logged_in
  end
end
