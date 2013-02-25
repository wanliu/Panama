class Admins::Shops::TemplatesController < Admins::Shops::SectionController
  ajaxify_pages :new, :index, :edit

  before_filter :setup_template

  def new
    @template = Template.new
  end

  def index
    templates = current_shop.fs["templates"]
    @templates = templates["*"]
    # .map do |f|
    #   {:name => f.name, :path => f.path, :created_at => f.created_at, :updated_at  => f.updated_at }
    # end
    @heads = [:name, :path, :created_at, :updated_at]
  end

  def edit
    name = params[:id]
    @template = Template.find(name)
  end

  def setup_template
    Template.setup(current_shop)
  end

  def update
    @template = Template.find(params[:id])
    @template.data = params[:template][:data]
    render :text => :ok
  end

end
