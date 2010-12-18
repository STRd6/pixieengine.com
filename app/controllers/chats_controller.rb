class ChatsController < ApplicationController
  def publish
    if current_user
      display_name = current_user.display_name
    else
      display_name = "Anonymous"
    end

    Juggernaut.publish("/chats", {
      :message => params[:body],
      :time => Time.now.strftime("%I:%M%p"),
      :name => display_name
    })

    Chat.create({ :user => current_user, :text => params[:body] })

    render :nothing => true
  end

  def active_users
    respond_to do |format|
      format.json do
        render :json => {
          :users => User.logged_in.map {|user| {:name => user.display_name } }
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
