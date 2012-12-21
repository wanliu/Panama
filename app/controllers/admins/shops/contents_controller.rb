class Admins::Shops::ContentsController < Admins::Shops::SectionController
  include Apotomo::Rails::ControllerMethods
  
  before_filter :prepend_data, :only => [:new, :edit, :create, :update]

  ajaxify_pages :new, :index, :edit

  has_widgets do |root|
    root << widget(:search)
    root << widget(:button, :new_content)
    root << widget(:input, :content_name)
    root << widget(:content_select, :content_type)
    root << widget(:table, :source => @contents)
    container = root << widget(:container, :widget => :content_type)
    container << widget("contents/article", :article)
    root << widget(:template_combo_box, :choose_template, :shop => @current_shop)
  end

  def new
    @content = Content.new
  end

  def index
    @contents = current_shop.contents
  end

  def create
    content_params = {
      :shop_id => current_shop.id
    }.merge(params[:content])

    @content = Content.create(content_params)
    if @content.save
      render :js => "alert('save is ok!')"
    else
      respond_to do |format|
        format.js { render "error_report" }
      end
    end
  end

  def edit
    @content = current_shop.contents.find(params[:id])
  end

  def update
    @content = current_shop.contents.find(params[:id])
    @content.update_attributes(params[:content])
    if @content.save
      render :js => "alert('save is ok!')"
    else
      respond_to do |format|
        format.js { render "error_report" }
      end
    end    
  end

  def destroy
    @content = current_shop.contents.find(params[:id])
    if @content
      @content.destroy
      render :js => "console.log(this)"
    else

    end
  end

  def prepend_data
    @templates = current_shop.fs['templates/*'].map do |f|
      f.path.sub /\/_shops\/\w+\//, ''
    end

    @contents =  [{value: 'article', text: 'Article'}, 
      {value: 'text', text: 'Text'},
      {value: 'datetime', text: 'Date && Time'},
      {value: 'query_language', text: 'Data Query'},
      {value: 'page', text: 'Page'}]
  end
end