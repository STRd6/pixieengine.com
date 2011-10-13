class ChatsController < ApplicationController
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  respond_to :html, :json

  def create
    text = auto_link(params[:body], :sanitize => false)

    cleaned_text = Sanitize.clean(text, :elements => ['a', 'img'],
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
      Chat.create({ :user => current_user, :text => cleaned_text })
    end

    render :nothing => true
  end

  def recent
    respond_to do |format|
      format.json do
        chats = Chat.recent.reverse.map do |chat|
          {
            :user_id => chat.user ? chat.user.id : 0,
            :id => chat.id,
            :name => chat.user_name,
            :time => chat.time,
            :message => chat.text.html_safe
          }
        end

        render :json => { :chats => chats }
      end
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
