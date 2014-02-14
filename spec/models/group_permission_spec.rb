#encoding: utf-8
require 'spec_helper'

describe GroupPermission, "组的权限模型" do

	it{ should belong_to(:group) }
	it{ should belong_to(:permission) }


	it "拥有属性" do
		group_permission = GroupPermission.new
		group_permission.should respond_to(:group_id)
		group_permission.should respond_to(:permission_id)
		group_permission.should respond_to(:group)
		group_permission.should respond_to(:permission)
	end
end
