class TableWidget < CommonWidget
  helper TableHelper

  attr_reader  :ignore_names

  AVAILABLE_OPTIONS_NAMES = %w(add_column modify_column hide_column heads nest_table_field children_field adapter)

  def display(records = [], model = nil, *args, &block)
    @records = records
    @model = model

    _options = args.first
    @heads = _options[:heads]

    locals = {
      records: records
    }

    locals.merge! default_options

    if args.length > 0
      table_options = args.shift

      locals.merge! table_options
      locals[:options] = table_options.slice(*AVAILABLE_OPTIONS_NAMES.map(&:to_sym))
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
    [args[0] , args[1], args[2]]
  end

  def default_fields
    if @model.nil?
      if not (@records && @records.is_a?(Array) && @records.first)
        if !@heads.nil?
          @fields = @heads
        else
          raise ArgumentError.new("can't get records Model information, please pass :model argument")          
        end
      else
        @klass = @records.first.class
        @record = @klass.new
        @record.attributes.keys - ignore_names
      end
    else
      @klass = @model
      @record = @klass.new
      @record.attributes.keys - ignore_names
    end
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
