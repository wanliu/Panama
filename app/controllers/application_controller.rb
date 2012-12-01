class ApplicationController < ActionController::Base
  include ApplicationHelper
  protect_from_forgery
  
  helper_method :current_user

  def login_required
    if !current_user
      respond_to do |format|
        format.html  {
          redirect_to '/auth/wanliuid'
        }
        format.json {
          render :json => { 'error' => 'Access Denied' }.to_json
        }
      end
    end
  end

  protected
  def content_tpl_path
    Rails.root.join "/tmp/templates"
  end

  def generate_template(resource, options)
    tpl = Tempfile.new(['shop', '.html.erb'], content_tpl_path)
    tpl.write(resource.read)
    tpl_name = tpl.path.gsub(/^(.*?)\.html\.erb/, '\1')
    begin
      yield(tpl_name, options)
    ensure
      tpl.unlink
    end
  end

  def render_content(route, *opts)
    content = Content.lookup_for(route)
    if content && content.template 
      generate_template(content.template) do |tpl_name, options|
        prepend_tpl_view_path
        inital = extract_temp_options opts
        render_content_template tpl_name, inital
      end
    end
  end


  def render_content_template(tpl_file, inital = {})
    render tpl_file
  end

  def prepend_tpl_view_path
    tmpdir = Rails.root.join(content_tpl_path)
    `mkdir #{tmpdir}`
    perpend_view_path tmpdir    
  end
end
