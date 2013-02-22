source 'http://ruby.taobao.org'

gem 'rails', '3.2.8'

# database orm adapter
gem 'mysql2', '~> 0.3.11'
gem 'mongoid', '~> 3.0.0'

# acts_as_tree
gem 'mongoid-tree',  '~> 1.0.1', :require => 'mongoid/tree'
gem 'ancestry', '~> 1.3.0'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', '~> 0.10.2', :platforms => :ruby
  gem 'anjlab-bootstrap-rails', '>= 2.2', :require => 'bootstrap-rails'
  gem 'uglifier', '>= 1.0.3'
  gem 'compass-rails', '~> 1.0.3'
  gem 'compass-h5bp', '~> 0.1.0'
  gem 'ejs', '~> 1.1.1'
end

gem 'cache_digests', '~> 0.2.0'
gem 'jquery-rails', '~> 2.1.3'
gem 'html5-rails', '~> 0.0.6'
gem 'requirejs-rails', '~> 0.9.0'

gem 'omniauth', '~> 1.1.1'
gem 'omniauth-oauth2', '~> 1.1.1'

# gem 'cells'
gem 'apotomo', '~> 1.2.3'

# gem 'widget_ui', :github => 'hysios/widget_ui'

# markup

gem 'github-markup', '~> 0.7.4'
gem 'redcarpet', '~> 2.2.2'


# form helper
gem 'simple_form', '~> 2.0.4'

gem 'vfs', '~> 0.4.8'

# css arrow
gem 'compass-css-arrow', '~> 0.0.3'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# image uploader
gem "carrierwave", '~> 0.8.0'
gem "carrierwave-mongoid", '~> 0.1.0', :require => 'carrierwave/mongoid'
gem "carrierwave-upyun", '~> 0.1.6'
gem 'rack-raw-upload', '~> 1.1.1'
gem "rest-client", '~> 1.6.7'

# rmagick
gem "mini_magick", '~> 3.4'

gem "amqp", "~> 0.9.0" # optionally: :git => "git://github.com/ruby-amqp/amqp.git", :branch => "0.9.x-stable"



# To use debugger
#
# Pagination
gem 'kaminari', '~> 0.14.1'

# Faye
gem 'faye-rails', '~> 1.0.6'

gem 'omniauth-wanliu', "0.1.0", :github => "wanliu/omniauth-wanliu"

gem 'state_machine', '~> 1.1.2'

group :development, :test do
  gem 'debugger', '~> 1.2.2'
  gem 'thin', '~> 1.5.0'
  gem 'hirb', '~> 0.7.0'
  gem 'rb-readline', '~> 0.4.2'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'guard-spork'
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
  gem 'ruby_gntp'
  gem 'growl'
  gem 'factory_girl_rails'
  gem 'rspec', '~> 2.12.0'
  gem 'rspec-rails', '~> 2.12.0'
  gem 'shoulda-matchers'
  gem 'cucumber-rails', '~> 1.3.0', :require => false
  gem 'simplecov', '~> 0.7.1', :require => false
  gem 'jasmine'
  # gem 'better_errors'
  # gem 'binding_of_caller'
end

group :test do
  # database_cleaner is not required, but highly recommended
  gem 'database_cleaner', '~> 0.9.1'
  gem 'spork', '~> 1.0rc'
  gem "fakefs", :require => "fakefs/safe"
end

gem "friendly_id", "~> 4.0.9" # Note: You MUST use 4.0.9 or greater for Rails 3.2.10
