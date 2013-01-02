config = YAML.load(File.open("#{::Rails.root}/config/oauth.yml").read)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, config['github']['key'], config['github']['secret'],
    scope: "repo"

  provider :google_oauth2, config['google']['key'], config['google']['secret'],
    access_type: 'online',
    scope: %w[
      https://www.google.com/m8/feeds/
      https://mail.google.com/
      https://www.googleapis.com/auth/userinfo.email
      https://www.googleapis.com/auth/userinfo.profile
    ].join(',')
end
