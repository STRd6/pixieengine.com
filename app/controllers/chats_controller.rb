class ChatsController < ApplicationController
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  def publish
    if current_user
      display_name = current_user.display_name
    else
      display_name = "Anonymous"
    end

    text = auto_link(params[:body])

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

    Juggernaut.publish("/chats", {
      :message => cleaned_text,
      :time => Time.now.strftime("%I:%M%p"),
      :name => display_name
    })

    Chat.create({ :user => current_user, :text => cleaned_text })

    render :nothing => true
  end

  def active_users
    respond_to do |format|
      format.json do
        render :json => {
          :users => User.logged_in.map { |user| {:name => user.display_name } }
        }
      end

      format.js do
        render :update do |page|
          page.replace_html 'active_users', :partial => 'shared/active_users'
        end
      end
    end
  end
end
