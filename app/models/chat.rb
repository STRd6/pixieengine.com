class Chat < ActiveRecord::Base
  belongs_to :user

  scope :recent, order("chats.created_at DESC").limit(15)
end
