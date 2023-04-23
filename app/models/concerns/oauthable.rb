module Oauthable
  def self.included(model)
    model.class_eval do
      has_many :oauth_tokens
    end
  end

  def token_for(provider)
    if oauth_token = oauth_tokens.find_by_provider(provider)
      oauth_token.token
    end
  end

  def update_oauth(provider, token)
    oauth_tokens
      .find_or_initialize_by_provider(provider)
      .update(token: token)
  end
end
