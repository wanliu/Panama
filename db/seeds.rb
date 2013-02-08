# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Category.root = Category.create(:name => :root) unless Category.root

@root = Category.find_or_create_by(:name => '_products_root')
product_category_file = Rails.root.join("config/product_category.yml")
@root.load_file(product_category_file)

bank_file = Rails.root.join("config/bank.yml")

Bank.load_file(bank_file)
