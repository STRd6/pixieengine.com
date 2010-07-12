class Link < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  self.default_url_options = { :host => "pixie.strd6.com" }

  belongs_to :user
  belongs_to :target, :polymorphic => true

  validates_presence_of :user, :token, :target

  before_validation :on => :create do
    self.token = ActiveSupport::SecureRandom.hex(8)
  end

  def to_s
    return link_token_url(token)
  end
end
