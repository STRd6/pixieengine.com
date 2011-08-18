class Comment < ActiveRecord::Base
  belongs_to :commenter, :class_name => "User"
  belongs_to :commentee, :class_name => "User"
  belongs_to :commentable, :polymorphic => true, :counter_cache => true

  before_validation(:on => :create) do
    self.commentee ||= commentable.user
  end

  after_create :notify_commentee

  validates_presence_of :commenter, :commentable, :body

  scope :for_user, lambda {|user| where(:commentee_id => user)}

  def notify_commentee
    if commentee && commentee.site_notifications
      Notifier.comment(self).deliver
  end
  handle_asynchronously :notify_commentee
end
