config = YAML.load_file(Rails.root.join('config/application.yml'))
elasticsearch = config[Rails.env]["elasticsearch"] || {}

Tire.configure do
	url elasticsearch["url"] || ENV['ELASTICSEARCH_URL'] || "http://localhost:9200"
end