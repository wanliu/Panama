require 'orm_fs'

module ContentsHelper

  def fs
    '/'.to_dir
  end

  def render_content(content, fs = fs, options = {:layout => false})
    begin
      tpl = fs[content.template].read
      generate_template(tpl) do |tpl_name, options|
        prepend_tpl_view_path
        render_content_template tpl_name, options
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

  def render_content_template(tpl_file, options = {})
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
