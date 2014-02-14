# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :content do |f|
    name 'index'
    template 'templates/index'
    lock  true
  end

  factory :content_with_resources, :parent => :content do |c|
    c.after_create { |a| FactoryGirl.create(:resource, content: a) }
  end
end
