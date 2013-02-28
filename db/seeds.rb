# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'rake'

Category.create(:name => :root) unless Category.root

@root = Category.where(name: '_products_root').first_or_create(:name => '_products_root')
shops_category_file = Rails.root.join("config/shops_category.yml")
@root.load_file(shops_category_file)

bank_file = Rails.root.join("config/bank.yml")

Bank.load_file(bank_file)

def rake
  rake = Rake::Application.new
  Rake.application = rake
  rake.init
  rake.load_rakefile
  rake
end

rake['city:load'].invoke