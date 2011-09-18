APP_CONFIG = HashWithIndifferentAccess.new YAML.load_file("#{Rails.root}/config/settings.yml")
