require 'spec_helper'
require 'orm_fs'

describe "ORMFS" do
  let :root do
  	'/'.to_dir
  end

  it "root is existy" do
  	root.should_not be_nil
  end

  it "accessor a dir" do
  	root["test"].should be_kind_of(Vfs::UniversalEntry)
  end

  it "create a file to auto make parent dir" do
  	dir = root["test"]
  	dir['readme.txt'].write('hello world')
  	dir['readme.txt'].read.should match("hello world")
  	root["test"].dir?.should be_true
  end

  it "delete a file" do
  	dir = root["test"]
  	readme = dir['readme.txt'].write('hello world')
  	readme.destroy
  	readme.exist?.should be_false
  end

  it "delete a dir" do
  	dir = root["test"]
  	readme = dir['readme.txt'].write('hello world')
  	dir.destroy
  	dir.exist?.should be_false
  	dir["readme.txt"].file?.should be_false
  end

  it "list a dir all content" do
  	dir = root["test"]
  	readme = dir["readme.txt"].write("hello world")
  	rakefile = dir["Rakefile"].write('puts "this is ruby file #{__FILE__}"')
  	dir["*"].map(&:name).should include(*[readme, rakefile].map(&:name))
  end
end