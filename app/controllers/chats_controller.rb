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

  def recent
    respond_to do |format|
      format.json { render :json => Chat.recent.reverse }
    end
  end

  def active_users
    respond_to do |format|
      format.json do
        users = User.logged_in.map do |user|
          favorite_color = user.favorite_color || "000"
          favorite_color = (favorite_color[0] == "#" ? favorite_color[1..-1] : favorite_color)

          {
            :avatar => user.avatar.url(:thumb),
            :color => favorite_color != "FFFFFF" ? favorite_color : "000",
            :name => user.display_name,
            :id => user.id
          }
        end

        render :json => { :users => users }
      end
    end
  end
end
