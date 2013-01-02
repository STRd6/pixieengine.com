class OauthToken < ActiveRecord::Base
  belongs_to :user
  attr_accessible :provider, :token
end
