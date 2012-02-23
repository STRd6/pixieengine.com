class Comment < ActiveRecord::Base
  include Sanitization

  belongs_to :commenter, :class_name => "User"
  belongs_to :commentee, :class_name => "User"
  belongs_to :commentable, :polymorphic => true, :counter_cache => true

  before_validation(:on => :create) do
    self.commentee ||= commentable.user
  end

  after_create :notify_commentee

  validates :commenter, :commentable, :body, :presence => true

  scope :for_user, lambda {|user| where(:commentee_id => user)}

  def as_json(options={})
    {
      :commenter_id => commenter_id,
      :commenter_name => commenter.display_name,
      :id => id,
      :commentable_id => commentable ? commentable.id : -1,
      :commentable_type => commentable_type.downcase.pluralize,
      :commentable_img_src => commentable ? commentable.image.url(:thumb) : "",
      :avatar_src => commenter.avatar.url(:thumb),
      :body => sanitize(BlueCloth.new(body).to_html),
      :time => created_at.getutc.iso8601
    }
  end

  def notify_commentee
    if commentee && commentee.site_notifications
      Notifier.comment(self).deliver
    end
  end
  handle_asynchronously :notify_commentee
end
