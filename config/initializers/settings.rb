require "yaml"

config = YAML::load_file("#{Rails.root}/config/application.yml")[Rails.env]
Settings.defaults = config