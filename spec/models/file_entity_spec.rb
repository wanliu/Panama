# encoding: utf-8
require 'spec_helper'

describe FileEntity do
  fixtures :file_entities

  it { should validate_presence_of :stat }

  let (:root) { FileEntity.root }

  it "根目录" do
    dir = FileEntity.where(stat: 'directory', ancestry: nil).first
    dir.should == root
  end

  describe "文件功能" do
    it "建立目录" do
      dir = root.create_dir("test_dir")
      dir.should be_a_kind_of(FileEntity)

    end

    it "不给名字就会出错" do
      expect { root.create_dir '' }.to raise_error(StandardError)
    end

    it "建立目录?" do
      dir = root.create_dir("test_dir")
      dir.directory?.should be_true
    end

    it "建立文件" do
      file = root.create_file("test_file")
      file.should be_a_kind_of(FileEntity)
    end

    it "不给名字就会出错" do
      expect { root.create_file '' }.to raise_error(StandardError)
    end

    it "文件判断?" do
      file = root.create_file("test_file")
      file.file?.should be_true
    end

    it "文件句柄" do
      f = root.create_file("test_file")
      f.file.should respond_to(:read)

    end

    it "文件名匹配" do
      files = root.match "_shops"
      files.length.should == 1
      files.first.name.should match "_shops"
    end

    it "只有目录可以进行匹配" do
      f = root.create_file("test_file")
      expect { f.match "*" }.to raise_error(StandardError)
    end
  end
end
