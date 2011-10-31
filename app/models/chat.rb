class Chat < ActiveRecord::Base
  belongs_to :user

  scope :recent, order("chats.created_at DESC").limit(15)

  def as_json(options={})
    user_id = user ? user.id : 0

    if options[:only]
      super(options)
    else
      {
        :user_id => user_id,
        :id => id,
        :name => user_name,
        :time => time,
        :message => text.html_safe
      }
    end
  end

  def user_name
    user ? user.display_name : "Anonymous"
  end

  def time
    created_at.strftime("%l:%M%P")
  end
end
