module Memberships
  def self.included(model)
    model.class_eval do
      has_many :memberships, :as => :group, :dependent => :destroy
    end
  end

  def has_access?(user)
    user && (user == self.user || memberships.where(:user_id => user.id).any?)
  end
end
