class UserSession < Authlogic::Session::Base
  def self.oauth_consumer
    OAuth::Consumer.new(OAUTH_TOKEN, OAUTH_SECRET, {
      :site=>"http://twitter.com",
      :authorize_url => "http://twitter.com/oauth/authenticate"
    })
  end

  def to_key
     new_record? ? nil : [ self.send(self.class.primary_key) ]
  end
end
