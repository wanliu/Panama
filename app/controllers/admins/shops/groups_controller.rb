#encoding: utf-8
# describe: 权限组

class Admins::Shops::GroupsController < Admins::Shops::SectionController

    def index
        @groups = @current_shop.groups
        respond_to do |format|
            format.json{ render :json => @groups.as_json(root: false) }
            format.html
        end
    end

    private
end