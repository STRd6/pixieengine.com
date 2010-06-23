class Feedback < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :body

  after_create :send_email

  def send_email
    Notifier.received_feedback(self).deliver
  end
end
