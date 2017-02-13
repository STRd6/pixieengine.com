class Invite < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user, :token, :email, :to

  validates_format_of :email, :with => Authlogic::Regex.email
  validates_format_of :to, :with => /\A[A-Za-z0-9 ]*\Z/, :message => "should have a more personalized name"

  after_create do
    Notifier.invitation(self).deliver_later
  end

  before_validation :on => :create do
    self.token = SecureRandom.hex(8)
  end
end
