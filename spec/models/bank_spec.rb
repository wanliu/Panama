#encoding: utf-8

require 'spec_helper'

describe Bank, "银行模型" do

    it{ should validate_presence_of(:name) }
    it{ should validate_presence_of(:code) }

    it "检查属性" do
        b = Bank.new
        b.should respond_to(:name)
        b.should respond_to(:code)
    end


    describe "method load_file" do

        it "加载文件" do
            path = [Rails.root, "config/bank.yml"].join("/")
            Bank.load_file(path)
            banks = YAML::load_file(path)["bank"]
            banks.each do | v |
                v.each{ | bank, info | Bank.find_by(:name => info["name"]).should_not be_nil }
            end
        end
    end

    describe "method load_config" do

        it "加载配置" do
            path = [Rails.root, "config/bank.yml"].join("/")
            banks = YAML::load_file(path)["bank"]
            Bank.load_config(banks)
            banks.each do | v |
                v.each{ | bank, info | Bank.find_by(:name => info["name"]).should_not be_nil }
            end
        end

    end
end
