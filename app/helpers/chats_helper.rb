module ChatsHelper
  def display_name(chat)
    chat.user ? chat.user.display_name : "Anonymous"
  end

  def time(chat)
    chat.created_at.strftime("%I:%M%p")
  end
end
