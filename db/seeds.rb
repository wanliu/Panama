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
  PanamaCore::VFS.load_panama_files

  load_categories

  load_banks

  load_cities
end

def load_categories

  @root = Category.root
  product_category_file = Rails.root.join("config/product_category.yml")
  @root.load_file(product_category_file)
end

def load_banks
  bank_file = Rails.root.join("config/bank.yml")
  Bank.load_file(bank_file)
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


initialize_data

