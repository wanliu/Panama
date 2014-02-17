class Admins::Shops::TemplatesController < Admins::Shops::SectionController
  ajaxify_pages :new, :index, :edit

  def new
    @template = Template.new
  end

  def index
    templates = shop_fs["templates"]
    @templates = templates["*"]
    # .map do |f|
    #   {:name => f.name, :path => f.path, :created_at => f.created_at, :updated_at  => f.updated_at }
    # end
    @heads = [:name, :path, :created_at, :updated_at]
  end

  def edit
    name = params[:id]
    @template = Template.find(name, shop_fs)
  end

  def update
    @template = Template.find(params[:id], shop_fs)
    @template.data = params[:template][:data]
    render :text => :ok
  end

  private

  def shop_fs
    current_shop.fs
  end
end
