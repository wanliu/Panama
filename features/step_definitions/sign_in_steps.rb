 # encoding: utf-8
begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end
require 'cucumber/formatter/unicode'
$:.unshift(File.dirname(__FILE__) + '/../../lib') 


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

Given /我已经在首页了/ do 
  visit "/"
end

Then /我将看到一个(.*)的信息/ do |msg|
  page.should have_content msg
end
