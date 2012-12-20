class Admins::Shops::ContentsController < Admins::Shops::SectionController
  include Apotomo::Rails::ControllerMethods
  
  ajaxify_pages :new, :index, :edit

  has_widgets do |root|
    root << widget(:search)
    root << widget(:button, :new_content)
    root << widget(:input, :content_name)
    root << widget(:content_select, :choose_content)
    root << widget(:table, :source => @contents)
    root << widget(:container, :widget => :choose_content)
    root << widget(:template_combo_box, :choose_template, :shop => @current_shop)
  end

  def index
    @contents = current_shop.contents
  end

  def edit
    @content = current_shop.contents.find(params[:id])
  end

  def destroy
    @content = current_shop.contents.find(params[:id])
    if @content
      #  @content.destroy
      render :js => "console.log(this)"
    else

    end
  end
end