class Visit < ActiveRecord::Base
  belongs_to :user

  def self.track(user, controller, action, session_id)
    Visit.create(:user => user, :controller => controller, :action => action, :session_id => session_id) unless controller == 'chats'
  end

  def self.daily_active_report(limit = 30)
    Visit.select("COUNT(DISTINCT COALESCE(CAST(user_id AS varchar), session_id)) as count, date_trunc('day', created_at) AS day").group("date_trunc('day', created_at)").order("day DESC").limit(limit)
  end
end
