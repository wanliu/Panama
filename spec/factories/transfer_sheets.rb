#encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transfer_sheet do |f|
    person "张三 "
    code "456444454654654654"
    bank "中国农业银行"
    f.order_transaction :order_transaction
  end
end
