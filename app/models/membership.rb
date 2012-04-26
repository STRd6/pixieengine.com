class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group, :polymorphic => true, :counter_cache => true

  after_create :notify_member

  def notify_member
    Notifier.notify_member(self).deliver unless self.user.email.blank?
  end
end
