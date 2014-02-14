#encoding: utf-8
# describe: 权限组

class Admins::Shops::GroupsController < Admins::Shops::SectionController

    def index
        @groups = @current_shop.groups
        respond_to do |format|
            format.json{ render :json => @groups.as_json }
            format.html
        end
    end

    def permissions
        @group = ShopGroup.find(params[:id])
        respond_to do |format|
            format.json{ render json: @group.permissions.as_json }
        end
    end

    def check_permissions
        @group = ShopGroup.find(params[:id])
        add_pers, rm_pers = inspect_check_permissions_opts
        @group.remove_permission(rm_pers)
        @group.add_permission(add_pers)
        respond_to do |format|
            format.json{ render json: @group.permissions.as_json }
        end
    end

    def create
        @shop_group = ShopGroup.new(params[:shop_group])
        @shop_group.shop_id = current_shop.id
        respond_to do |format|
            if @shop_group.save
                format.json{ render json: @shop_group.as_json }
            else
                format.json{ render json: @shop_group.errors.messages, status: 403 }
            end
        end
    end

    def destroy
        @shop_group = ShopGroup.find(params[:id])
        @shop_group.destroy
        respond_to do | format |
            format.json{ render json: {} }
        end
    end

    private
    def inspect_check_permissions_opts
        add_pers, rm_pers = [], []
        params[:permissions].each do |i, pg|
            if pg["status"] == "true"
                add_pers << pg["permission_id"]
            else
                rm_pers << pg["permission_id"]
            end
        end
        [add_pers, rm_pers]
    end
end