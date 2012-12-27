class Admins::Shops::CategoriesController < Admins::Shops::SectionController

  class IncorretDescentantNode < StandardError; end

  before_filter :form_params, :only => [:new, :create]

  ajaxify_pages :new, :edit, :create

  has_widgets do |root|
    root << widget(:table, :source => @children)
  end

  def index
    @category = current_shop.category
    @children = @category.children
  end

  def new
    @indent += 1
    @category = Category.new
  end

  def create
    @category = @parent.children.create(params[:category])
    @form_id = params[:form_id]
    render "edit_row"
  end

  def form_params
    @parent = params[:parent_id].blank? ? current_shop.category : Category.find(params[:parent_id])
    if !(@parent == current_shop.category || @parent.descendant_of?(current_shop.category))
      throw IncorretDescentantNode.new(t('errors.incorret_descentant_node', 
        :node => params[:parent_id],
        :parent => @parent.id))
    end
    @indent = params.fetch(:indent, 0).to_i
  end
end
