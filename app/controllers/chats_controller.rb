class ChatsController < ApplicationController
  respond_to :html, :json

  def create
    text = auto_link(params[:body], :sanitize => false, :html => { :target => '_blank' })

    cleaned_text = sanitize(text)

    unless cleaned_text.blank?
      chat = Chat.create({ :user => current_user, :text => cleaned_text })
    end

    respond_with chat
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
    respond_with Chat.recent.reverse
  end

  def active_users
    @active_users = User.logged_in

    render :nothing => true
  end
end
