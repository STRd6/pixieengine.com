class Comment < ActiveRecord::Base
  extend Memoist
  include Sanitization

  include PublicActivity::Model
  tracked only: :create,
    owner: :commenter,
    recipient: :commentee

  belongs_to :commenter,
    :class_name => "User"
  belongs_to :commentee,
    :class_name => "User"
  belongs_to :commentable,
    :polymorphic => true,
    :counter_cache => true

  belongs_to :root,
    :class_name => "Comment"

  # Comments can be in reply to specific comments
  belongs_to :in_reply_to,
    :class_name => "Comment",
    :inverse_of => :replies
  has_many :replies,
    :class_name => "Comment",
    :inverse_of => :in_reply_to,
    :foreign_key => "in_reply_to_id"

  before_validation(:on => :create) do
    if in_reply_to
      self.root = in_reply_to.root
    else
      self.root = self
    end

    self.commentee ||= commentable.user
  end

  after_create :create_mention_activities

  after_commit :notify_commentee, on: :create
  after_create do
    if commentable.instance_of? Sprite
      commentable.update_score
      commentable.save
    end
  end

  validates :commenter, :commentable, :body, :presence => true
  # Don't allow exact duplicate comments by same person on same item
  validates :body,
    uniqueness: {scope: [:commentable_id, :commenter_id]},
    presence: true

  scope :for_user, lambda {|user| where(:commentee_id => user)}

  def as_json(options={})
    data = {
      :commenter => commenter.comment_json,
      :id => id,
      :body => body,
      :time => time,
    }

    return data
  end

  def time
    created_at.getutc.iso8601
  end

  def mentioned_users
    mention_regex = /@([A-Za-z0-9_-]+)/

    mentioned_display_names = body.scan(mention_regex).flatten

    if mentioned_display_names.size > 0
      User.where(["display_name IN (?)", mentioned_display_names]).limit(16)
    else
      []
    end
  end
  memoize :mentioned_users

  def create_mention_activities
    mentioned_users.each do |mentioned_user|
      # Skip self-mentions and commentee mentions and commenters the user follows
      unless mentioned_user == commenter || mentioned_user == commentee
        create_activity({
          action: "mention",
          recipient: mentioned_user,
          owner: commenter,
        })
      end
    end
  end

  def notify_commentee
    if commentee && commentee.site_notifications && commentee != commenter
      Notifier.comment(self).deliver_later
    end
  end
end
