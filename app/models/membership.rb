class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group, :polymorphic => true, :counter_cache => true

end
