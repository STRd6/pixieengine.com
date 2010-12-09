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

    render :nothing => true
  end

  def active_users
    render :json => {
      :users => User.logged_in.map {|user| {:name => user.display_name } }
    }
  end
end
