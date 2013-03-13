require 'orm_fs'
require 'action_controller/record_identifier'

module ContentsHelper
  include ActionController::RecordIdentifier

  def fs
    '/'.to_dir
  end

  def render_content(content, fs = fs, render_options = {:layout => false})
    begin
      tpl = fs[content.template].read
      generate_template(tpl) do |tpl_name, options|
        prepend_tpl_view_path
        render_content_template tpl_name, render_options
      end
    rescue Vfs::Error => e
      raise "template file :#{content.template} not found"
    end
  end

  def content_tpl_path
    path = Rails.root.join "tmp/templates"
    FileUtils.mkdir_p path
    path
  end

  def generate_template(content, options = {})
    tpl = Tempfile.new(['content', '.html.erb'], content_tpl_path.to_s)
    tpl.write(content)
    tpl.close
    tpl_name = tpl.path.gsub(/^(.*?)\.html\.erb/, '\1')
    begin
      yield(tpl_name, options)
    ensure
      tpl.unlink
    end
  end

  def render_content_template(tpl_file, _options = {})
    options = {}
    locales_options = _options.delete(:locales) || _options
    options[:layout] = _options.delete(:layout) || false
    # options[:locales] = locales_options
    render tpl_file, options
  end

  def prepend_tpl_view_path
    tmpdir = Rails.root.join(content_tpl_path)
    prepend_view_path tmpdir
  end

  def extract_temp_options(*args)
    args.last
  end
end
