config = YAML.load(File.open("#{::Rails.root}/config/oauth.yml").read)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, config['github']['key'], config['github']['secret'], scope: "repo"
end
