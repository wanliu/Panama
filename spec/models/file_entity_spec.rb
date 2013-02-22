# encoding: utf-8
require 'spec_helper'

describe FileEntity do
  pending "add some examples to (or delete) #{__FILE__}"

  it { should validate_presence_of :stat }

  let (:root) { FileEntity.root }
  describe "文件功能" do
    it "建立目录" do
      dir = root.create_dir("test_dir")
      dir.should be_a_kind_of(FileEntity)
    end
  end
end
