# encoding: utf-8

# source 'https://rubygems.org'
source 'http://ruby.taobao.org'

gem 'rails', '3.2.15'
# database orm adapter
gem 'mysql2', '~> 0.3.11'
gem 'mongoid', '~> 3.0.0'

#use this soft delete
gem "acts_as_paranoid", "~>0.4.0"

# acts_as_tree
gem 'mongoid-tree',  '~> 1.0.1', :require => 'mongoid/tree'
gem 'ancestry', '~> 1.3.0'
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'coffee-script-source', '~> 1.4.0'
  # gem "coffee-script-source", "~> 1.6.2"

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', '~> 0.10.2', :platforms => :ruby
  gem 'anjlab-bootstrap-rails', '2.3.1.2', :require => 'bootstrap-rails'
  gem 'uglifier', '>= 1.0.3'
  gem 'compass-rails', '~> 1.1.2'
  gem 'compass-h5bp', '~> 0.1.2'
  gem 'ejs', '~> 1.1.1'
  gem 'font-awesome-sass-rails'
end

gem 'cache_digests', '~> 0.2.0'
gem 'jquery-rails', '2.1.4'
gem 'html5-rails', '~> 0.0.6'
# gem 'requirejs-rails', '~> 0.9.0'

gem 'omniauth', '~> 1.1.1'
gem 'omniauth-oauth2', '~> 1.1.1'

# gem 'cells'
gem 'apotomo', '~> 1.2.3'
gem 'redis-rails'
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
# gem 'capistrano', '2.9.0', :require => false
# image uploader
gem "carrierwave", '~> 0.8.0'
gem "carrierwave-mongoid", '~> 0.1.0', :require => 'carrierwave/mongoid'
gem "carrierwave-upyun", '~> 0.1.6'
gem 'rack-raw-upload', '~> 1.1.1'
gem "rest-client", '~> 1.6.7'

# rmagick
gem "mini_magick", '~> 3.4'

gem "bunny", "~> 1.0.4"

# Pagination
gem 'kaminari', '~> 0.14.1'
gem 'kuaiqian', "~> 0.0.1", :github => "huxinghai1988/kuaiqian"
gem 'tire_update_by_query', "~> 0.0.7", :github => "huxinghai1988/tire_update_by_query"


gem 'omniauth-wanliu', "0.1.1", :github => "wanliu/omniauth-wanliu"

gem 'state_machine', '~> 1.1.2'

group :development, :test do
  gem "selenium-webdriver", "~> 2.27.0"
  gem 'hirb', '~> 0.7.0'
  # gem 'rb-readline', '~> 0.4.2'
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
  gem 'rvm-capistrano'
  # gem 'debugger', '~> 1.2.2'
  gem 'byebug'
  gem "debugger-pry", :require => "debugger/pry"
  # gem 'pry-rails'
  # gem 'zeus'
  # gem 'coffee-rails-source-maps'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'yard'
  # gem 'yard-pygmentsrb'
end

group :test do
  # database_cleaner is not required, but highly recommended
  gem 'database_cleaner', '~> 0.9.1'
  gem 'spork', '~> 1.0rc'
  gem "fakefs", :require => "fakefs/safe"
end

gem "friendly_id", "~> 4.0.9" # Note: You MUST use 4.0.9 or greater for Rails 3.2.10
gem "ac_uniquify", "~> 0.1.0"
gem 'draper', '~> 1.0'
gem 'activeadmin', '0.5.1'
gem 'passenger'
gem "nested_form"
# 默认值
gem "default_value_for"
gem 'cancan'

gem 'activemerchant'
gem 'activemerchant_patch_for_china'
gem 'geocoder', :github => 'mrichie/geocoder'
gem 'ruby-hmac'
gem "hiredis", "~> 0.4.0"
gem 'rails_autolink'
gem 'whenever', :require => false
gem 'chinese_pinyin', '0.4.1'
gem 'rmmseg-cpp-huacnlee', '0.2.9'
gem 'redis-namespace','~> 1.0.2'
# gem 'redis-search', '0.9.0'
gem 'redis'
gem "wicked"

## Search
gem 'tire', :github => "hysios/tire"
gem 'tire-settings', :github => "hysios/tire-settings"
gem 'yajl-ruby'

gem "delayed_job_active_record"
gem "daemons"
gem 'rubyzip', '< 1.0.0'
gem "puma"

gem 'rails_emoji', '~> 1.7.1', :github => "jsw0528/rails_emoji"
gem "settings", :github => "hysios/settings"
gem 'newrelic_rpm'