require 'orm_fs'
require 'action_controller/record_identifier'

module ContentsHelper
  include ActionController::RecordIdentifier

  def fs
    '/'.to_dir
  end

  def render_content(content, render_options = { :layout => false })
    begin
      if content && content.try(:template)
        tpl = content.template.data
        generate_template(tpl, render_options) do |tpl_name, options|
          prepend_tpl_view_path
          render_content_template tpl_name, render_options
        end
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
    prefix = "content"

    tpl = Tempfile.new([prefix, '.html.erb'], content_tpl_path.to_s)
    tpl.write(content)
    tpl.close
    tpl_name = tpl.path.gsub(/^(.*?)\.html\.erb/, '\1')
    tpl_name = File.basename(tpl_name, '.html.erb')
    begin
      yield(tpl_name, options)
    ensure
      tpl.unlink
    end
  end

  def render_content_template(tpl_file, _options = {})
    options = {}
    locals_options = _options.delete(:locals) || _options
    options[:layout] = _options.delete(:layout) || false
    options[:locals] = locals_options
    if in_view?
      render :template => tpl_file, :locals => options[:locals]
    else
      render :template => tpl_file, :layout => options[:layout], :locals => options[:locals]
    end
  end

  def in_view?
    !respond_to?(:view_context)
  end

  def prepend_tpl_view_path
    tmpdir = Rails.root.join(content_tpl_path)
    if !respond_to?(:controller)
      prepend_view_path tmpdir
    else
      controller.prepend_view_path tmpdir
    end
  end

  def extract_temp_options(*args)
    args.last
  end

  def values
    @__values ||= {}
  end

  def value_for(name)
    if in_view?
      instance_exec &values[name] if values[name].is_a?(Proc)
    else
      view_context.instance_exec &values[name] if values[name].is_a?(Proc)
    end
  end

  def register_value(name, &block)
    values[name] = block
  end
end
