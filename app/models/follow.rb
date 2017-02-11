class Follow < ActiveRecord::Base
  belongs_to :follower, :class_name => "User", :counter_cache => :following_count
  belongs_to :followee, :class_name => "User", :counter_cache => :followers_count

  validates :followee_id, uniqueness: { scope: :follower_id, message: "Already following"  }

  include PublicActivity::Model
  tracked only: :create, owner: :follower, recipient: :followee
end
