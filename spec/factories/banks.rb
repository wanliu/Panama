#encoding: utf-8

FactoryGirl.define do

  factory :boc, :class => Bank do
    name "中国银行"
    code "boc"
  end

  factory :icbc, :class => Bank do
    name "工商银行"
    code "icbc"
  end

  factory :cbc, :class => Bank do
    name "建设银行"
    code "cbc"
  end
end