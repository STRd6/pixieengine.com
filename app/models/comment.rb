class Comment < ActiveRecord::Base
  belongs_to :commenter, :class_name => "User"
  belongs_to :commentee, :class_name => "User"
  belongs_to :commentable, :polymorphic => true, :counter_cache => true

  validates_presence_of :commenter, :commentable, :body

  scope :for_user, lambda {|user| where(:commentee_id => user)}
end
