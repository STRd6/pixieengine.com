module Oauthable
  def self.included(model)
    model.class_eval do
      has_many :oauth_tokens
    end
  end

  def update_oauth(provider, token)
    oauth_tokens
      .find_or_initialize_by_provider(provider)
      .update_attributes(token: token)
  end
end
