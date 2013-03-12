class Admins::Shops::CategoriesController < Admins::Shops::SectionController

  class IncorretDescentantNode < StandardError; end

  before_filter :form_params, :only => [:new, :create]

  ajaxify_pages :new, :edit, :create, :update

  has_widgets do |root|
    root << widget(:table, :source => @children)
  end

  def index
    # @shops_categories = current_shop.shops_category.descendants
    node = current_shop.shops_category
    @shops_categories = ShopsCategory.sort_by_ancestry(node.descendants)
    #@children = @shops_category.children
  end

  def new
    @indent += 1
    @shops_category = @parent.children.build
  end

  def create
    @shops_category = @parent.children.build(params[:shops_category])
    @shops_category.shop = current_shop
    @shops_category.save
    render :action => :edit
  end

  def destroy
    @shops_category = ShopsCategory.find(params[:id])
    if @shops_category == current_shop.shops_category || !@shops_category.descendant_of?(current_shop.shops_category)
      throw IncorretDescentantNode.new(t('errors.incorret_descentant_node',
        :node => params[:id],
        :parent => @current_shop.shops_category.id))
    end
    @shops_category.destroy
    render "report_destroy"
  end

  def update
    @shops_category = ShopsCategory.find(params[:id])
    @shops_category.update_attributes(safe_params)
    render :action => :edit
  end

  def form_params
    @parent = params[:parent_id].blank? ? current_shop.shops_category : ShopsCategory.find(params[:parent_id])
    # FIXED: don't use raise error ,change redirect_to
    if !(@parent == current_shop.shops_category || @parent.descendant_of?(current_shop.shops_category))
      throw IncorretDescentantNode.new(t('errors.incorret_descentant_node',
        :node => params[:parent_id],
        :parent => @parent.id))
    end
    @indent = @parent.indent
  end

  def category_children
    @category_children = Category.find_by(:name => params[:category_name]).children
    result = @category_children.map do | c |
      category = c.as_json
      category["category"].merge(:status => true) if c.children.count > 0
      category
    end
    render :json => result
  end

  private

  def safe_params
    params[:shops_category].slice(*white_list)
  end

  def white_list
    ShopsCategory.accessible_attributes
  end

end
