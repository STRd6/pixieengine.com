class ChatsController < ApplicationController
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  def create
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

    unless cleaned_text.blank?
      Chat.create({ :user => current_user, :text => cleaned_text })
    end

    render :nothing => true
  end

  def recent
    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html 'chats', :partial => 'shared/recent_chats'
        end
      end
    end
  end

  def active_users
    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html 'active_users', :partial => 'shared/active_users'
        end
      end
    end
  end
end
