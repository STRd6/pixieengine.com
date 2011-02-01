APP_CONFIG = HashWithIndifferentAccess.new YAML.load_file(File.join(Rails.root, "config", "settings.yml"))
