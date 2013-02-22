class Admins::Shops::CategoriesController < Admins::Shops::SectionController

  class IncorretDescentantNode < StandardError; end

  before_filter :form_params, :only => [:new, :create]

  ajaxify_pages :new, :edit, :create, :update

  has_widgets do |root|
    root << widget(:table, :source => @children)
  end

  def index
    # @categories = current_shop.category.descendants
    node = current_shop.category
    @categories = Category.sort_by_ancestry(node.descendants)
    #@children = @category.children
  end

  def new
    @indent += 1
    @category = @parent.children.build
  end

  def create
    @category = @parent.children.create(params[:category])
    render :action => :edit
  end

  def destroy
    @category = Category.find(params[:id])
    if @category == current_shop.category || !@category.descendant_of?(current_shop.category)
      throw IncorretDescentantNode.new(t('errors.incorret_descentant_node',
        :node => params[:id],
        :parent => @current_shop.category.id))
    end
    @category.destroy
    render "report_destroy"
  end

  def update
    @category = Category.find(params[:id])
    @category.update_attributes(params[:category])
    render :action => :edit
  end

  def form_params
    @parent = params[:parent_id].blank? ? current_shop.category : Category.find(params[:parent_id])
    # FIXED: don't use raise error ,change redirect_to
    if !(@parent == current_shop.category || @parent.descendant_of?(current_shop.category))
      throw IncorretDescentantNode.new(t('errors.incorret_descentant_node',
        :node => params[:parent_id],
        :parent => @parent.id))
    end
    @indent = @parent.indent
  end
end
