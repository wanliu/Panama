# encoding: utf-8

Before do
  OmniAuth.config.test_mode = true
 # the symbol passed to mock_auth is the same as the name of the provider set up in the initializer
  OmniAuth.config.mock_auth[:wanliuid] = {
      "uid"=>"1234",
      "info"=>{"login"=>"test_user"}
  }
end

After do
  OmniAuth.config.test_mode = false
end

Given /^我已经在商品 (.*) 显示页面$/ do |product_name|
  product = Product.find_by(name: product_name)
  visit product_path(product)
end

Given /^我已经单击商品规格中的 N中码$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^我已经单击商品颜色中的 绿色$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^我已经输入商品数量 (\d+)$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^我按下 立刻购买$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^我的页面将跳转到 付款页面$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^我已经单击商品规格中的 L大码$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^我已经单击商品颜色中的 红色$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^我已经单击商品规格中的 XL加大码$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^我已经单击商品颜色中的 黑色$/ do
  pending # express the regexp above with the code you wish you had
end

When /^我按下 加入购物车$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^我将看到购物中商品数量显示 (\d+)$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^我已经单击商品规格中的 XL大码$/ do
  pending # express the regexp above with the code you wish you had
end
