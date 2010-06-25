class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.require_password_confirmation = false
  end

  has_many :sprites

  after_create do
    Notifier.welcome_email(self).deliver
  end

  def to_s
    display_name
  end

  def display_name
    if super.blank?
      "Anonymous#{id}"
    else
      super
    end
  end
end
