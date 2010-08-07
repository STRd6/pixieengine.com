class Invite < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user, :token, :email

  after_create do
    Notifier.welcome_email(self).deliver unless email.blank?
  end

  before_validation :on => :create do
    self.token = ActiveSupport::SecureRandom.hex(8)
  end

  def to_s
    return link_token_url(token)
  end
end
