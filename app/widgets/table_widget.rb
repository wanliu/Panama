class TableWidget < CommonWidget
  helper TableHelper

  attr_reader  :ignore_names

  def display(records = [], model = nil, *args, &block)
    @records = records
    @model = model

    if model.nil? && records.size == 0 
      raise ArgumentError.new("can't get records Model information, please pass :model argument")
    end

    locals = {
      records: records
    }

    locals.merge! default_options

    if args.length > 0
      table_options = args.shift

      locals.merge! table_options
      locals[:options] = table_options.slice(:add_column, :hide_column)
    else
      locals[:options] = nil
    end
    # @options = options
    # @records = records
    render :locals => locals
  end


  protected 
  def ignore_names
    @ignore_names ||= ['_id', '_type']
  end

  def extract_table_options(args)
    [args[0] || {}, args[1] || {} , args[2] || {}]
  end

  def default_fields
    @klass = @model || @records.first.class
    @klass = @klass.is_a?(Symbol) ? @klass.to_s : @klass          
    @klass.fields.keys - ignore_names
  end

  def default_options
    {
      heads: default_fields - ignore_names,
      head_options: {
        class: ['table']
      },
      row_options: {},
      foot_options: {}
    }
  end
end
