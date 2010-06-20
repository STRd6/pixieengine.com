class User < ActiveRecord::Base
  acts_as_authentic

  before_validation(:on => :create) do
    self.reset_password
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
