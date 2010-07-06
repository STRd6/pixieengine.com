class Link < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, :polymorphic => true

  validates_presence_of :user, :token, :target

  before_validation :on => :create do
    self.token = ActiveSupport::SecureRandom.hex(8)
  end
end
