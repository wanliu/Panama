# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'rake'
require 'panama_core'


def initialize_data
  FileEntity.root
  PanamaCore::VFS.load_panama_files

  load_categories
  load_permission
  load_banks

  load_cities

  # load_delivery_types

  load_order_reason

  # load_pay_manner

  #load_delivery_manner

  # load_user_service

  # load_logistics
end

def load_categories
  @root = Category.root
  product_category_file = Rails.root.join("config/product_category.yml")
  @root.load_file(product_category_file)
end

def load_banks
  rake['bank:load'].invoke
end

def rake
  rake = Rake::Application.new
  Rake.application = rake
  rake.init
  rake.load_rakefile
  rake
end

def load_cities
  rake['city:load'].invoke
end

def load_delivery_types
  rake['delivery_type:load'].invoke
end

def load_order_reason
  rake['order_reason:load'].invoke
end

# def load_pay_manner
#   rake['pay_manner:load'].invoke
# end

def load_delivery_manner
  rake['delivery_manner:load'].invoke
end

def load_permission
  rake['permission:load'].invoke
end

initialize_data

