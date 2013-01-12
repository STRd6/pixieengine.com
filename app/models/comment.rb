class Comment < ActiveRecord::Base
  include Sanitization

  belongs_to :commenter, :class_name => "User"
  belongs_to :commentee, :class_name => "User"
  belongs_to :commentable, :polymorphic => true, :counter_cache => true

  belongs_to :root, :class_name => "Comment"

  # Comments can be in reply to specific comments
  belongs_to :in_reply_to, :class_name => "Comment", :inverse_of => :replies
  has_many :replies, :class_name => "Comment", :inverse_of => :in_reply_to, :foreign_key => "in_reply_to_id"

  before_validation(:on => :create) do
    if in_reply_to
      self.root = in_reply_to.root
    else
      self.root = self
    end

    self.commentee ||= commentable.user
  end

  after_create :notify_commentee

  validates :commenter, :commentable, :body, :presence => true
  # Don't allow exact duplicate comments by same person on same item
  validates :body, :uniqueness => {:scope => [:commentable_id, :commenter_id]}

  scope :for_user, lambda {|user| where(:commentee_id => user)}

  scope :recent_by_item_for_user, lambda {|user|
    select([:commentable_id, :commentable_type])
    .where{(commenter_id != user.id) & (commentee_id == user.id)}
    .group(:commentable_id, :commentable_type)
    .order("MAX(id) DESC")
    .limit(10)
  }

  def as_json(options={})
    data = {
      :commenter => commenter.comment_json,
      :id => id,
      :body => sanitize(BlueCloth.new(body).to_html),
      :time => created_at.getutc.iso8601
    }

    return data
  end

  def notify_commentee
    if commentee && commentee.site_notifications
      Notifier.comment(self).deliver
    end
  end
end
