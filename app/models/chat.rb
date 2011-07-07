class Chat < ActiveRecord::Base
  belongs_to :user

  scope :recent, order("chats.created_at DESC").limit(15)

  def user_name
    user ? user.display_name : "Anonymous"
  end

  def time
    created_at.strftime("%l:%M%P")
  end
end
