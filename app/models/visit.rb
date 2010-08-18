class Visit < ActiveRecord::Base
  belongs_to :user

  def self.track(user, controller, action)
    Visit.create(:user => user, :controller => controller, :action => action)
  end
end
