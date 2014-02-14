module TableBuilder
  class Base
    include ActionView::Helpers::TagHelper
  
    # include I18nHelper::Model::Helpers

    # model_klass :record, "record", Record
    attr_accessor :output_buffer, :options
    attr_reader :ignore_names, :content
    
    def initialize(records = nil, _options = {})
      @additional_heads = {}
      @hidden_heads = []
      @modify_heads = {}
      @heads = _options[:heads]
      @options = _options
      add_columns = options[:add_column] || []
      modify_columns = options[:modify_column] || []
      add_columns.each do |col|
        name = col.keys[0]
        value = col.values[0]
        @additional_heads[name] = {:name => name, :proc => value } 
      end

      modify_columns.each do |col|
        name = col.keys[0]
        value = col.values[0]
        @modify_heads[name] = {:name => name, :proc => value}
      end
      @hidden_heads = options[:hide_column] || []
    end

    def output_buffer 
      @output_buffer ||= OutputBuffer.new
    end

    def content_to(col)
      case col
      when DateTime, Time ,Date
        I18n.l col, :format => :short
      else
        col.to_s
      end
    end

    def customize_print(row, cell)
      return content_to(row[cell]) if @modify_heads[cell].nil?
      column = @modify_heads[cell]
      if column[:proc].is_a?(Proc)
        column[:proc].call(row)
      end
    end


    protected
    def adapter(row)
      case row
      when ::ActiveRecord::Base
        TableRowAdapter::ActiveRecord.new(row)
      when ::Mongoid::Document
        TableRowAdapter::Mongoid.new(row)
      when ::Hash
        TableRowAdapter::Hash.new(row)
      end
    end

    protected
      def cleanup!
        output_buffer.clear
      end

      def parse_head_args(args)
        [TableOptions.new(args[0]), TableOptions.new(args[1]), TableOptions.new(args[2])]
      end

      def parse_row_args(args)
        [TableOptions.new(args[0]), TableOptions.new(args[1])]
      end    
  end

  class TableBuilder < Base

    def table_head(heads = nil, *args)
      @heads = heads unless heads.nil?
      table_options, tr_options, th_options = parse_head_args args
      cleanup!

      output_buffer << tag("table", table_options, true)
      output_buffer << (content_tag :thead do 
        content_tag :tr, tr_options do 
          @heads.each do |column|
            output_buffer << content_tag(:th, I18n.t("table.heads.#{column}"), th_options)
          end
          @hidden_heads.each do |column|
            output_buffer << content_tag(:th, column, :class => "hide" )
          end
        end
      end)
      output_buffer
    end

    def table_row(row, *args)
      tr_options, td_options = parse_row_args args
      cleanup!
      output_buffer << content_tag(:tr, tr_options) do
        @heads.each do |column|
          output_buffer << content_tag(:td, td_options) do 
            column_sym = column.to_sym
            col = adapter(row).read_attribute(column_sym)
            if col.nil?
              callback = @additional_heads[column_sym][:proc] if @additional_heads[column_sym]
              output_buffer << callback.call(row) if callback
            else
              # todo: how to pass format options argument
              # todo: how to change time to user timezone
              output_buffer << customize_print(row, column_sym)
            end
          end
        end

        @hidden_heads.each do |column_sym|
          column_sym
          col = row.read_attribute(column_sym)
          output_buffer << content_tag(:td, :class => "hide") do 
            output_buffer << content_to(col)
          end
        end
      end

      if options[:nest_table_field]
        childs = row.send(options[:nest_table_field])
        if childs.size > 0
          output_buffer << content_tag(:tr, tr_options) do
            td_options[:colspan] = @heads.size
            output_buffer << content_tag(:td, td_options) do
              nest_table(childs, options) do |t, children|
                nest_options = options.merge({ :class => "table"})
                output_buffer << t.table_head(nil, nest_options)
                children.each do |r|
                  output_buffer << t.table_row(r)
                end
                output_buffer << t.table_footer
              end
            end
          end
        end
      end      

      output_buffer
    end


    def table_footer(options = nil)
      tag "/table", nil, true
    end

    def nest_table(record, options, &block)
      table = self.class.new(record, options)
      yield table, record if block_given?
      table
    end
  end

  class TreeTableBuilder < Base

    def table_head(heads = nil, *args)
      @heads = heads unless heads.nil?
      table_options, tr_options, th_options = parse_head_args args
      cleanup!

      output_buffer << tag("table", table_options, true)
      output_buffer << (content_tag :thead do 
        content_tag :tr, tr_options do 
          @heads.each do |column|
            output_buffer << content_tag(:th, I18n.t("table.heads.#{column}"), th_options)
          end
          @hidden_heads.each do |column|
            output_buffer << content_tag(:th, column, :class => "hide" )
          end
        end
      end)
      output_buffer
    end

    def table_row(row, *args)
      tr_options, td_options = parse_row_args args
      indent = tr_options[:indent] ||= 0
      output_buffer.push 
      # if indent > 0
      # cleanup!
      output_buffer << content_tag(:tr, tr_options) do
        @heads.each do |column|
          output_buffer << table_cell(row, column.to_sym, td_options)
        end

        @hidden_heads.each do |column_sym|
          output_buffer << table_cell(row, column_sym, {:class => "hide"})
        end
      end

      if options[:children_field]
        childs = row.send(options[:children_field])
        if childs.size > 0
          _tr_options = tr_options.clone
          indent = _tr_options[:indent] += 1
          _tr_options.add_or_replace_class "indent_#{indent}" do |_class|
            if _class.start_with?('indent_')
              "indent_#{indent}"
            else
              _class
            end
          end
          childs.each do |_row|
            output_buffer << table_row(_row, _tr_options, td_options)
          end
        end
      end

      output_buffer.pop
    end

    def table_cell(row, cell, options)
      content_tag(:td, options) do 
        col = adapter(row).read_attribute(cell)
        if col.nil?
          callback = @additional_heads[cell][:proc] if @additional_heads[cell]
          callback.call(row) if callback
        else
          customize_print(row, cell)
        end
      end      
    end

    def table_footer(options = nil)
      tag "/table", nil, true
    end
  end

  module TableRowAdapter
    class Base
      attr_reader :record 
      def initialize(record)
        @record = record
      end

      def read_attribute(column)
      end
    end

    class ActiveRecord < Base
      def read_attribute(column)
        record.read_attribute(column)
      end
    end

    class Mongoid < Base
      def read_attribute(column)
        record.read_attribute(column)
      end
    end

    class Hash < Base
      def read_attribute(column)
        record[column]
      end
    end
  end

  class TableOptions < Hash

    def initialize(_hash = nil)
      return super unless _hash

      throw ArgumentError.new("invalid params class, must hash object") unless _hash.is_a?(Hash)
      _hash.each do |key, value|
        self[key] = value
      end
      super nil
    end

    def add_class(value)
      old = self[:class]
      target = if old.nil?
        []
      elsif !old.is_a?(Array)
        [old]
      else
        old
      end
      target << value
      self[:class] = target
    end

    def replace_class(&block)
      classes = case self[:class]
                when NilClass
                  []
                when String
                  self[:class].split(' ')
                when Array
                  self[:class]
                when Symbol
                  [self[:class].to_s]
                else
                  throw ArgumentError.new("invalid class , must String, Array, Symbol")
                end

      self[:class] = classes.map {|c| yield c }
    end

    def add_or_replace_class(name, &block)
      if self[:class].nil?
        add_class(name)
      else
        replace_class(&block)
      end
    end
  end

  class OutputBuffer

    attr_accessor :buffer
    delegate :<<, :clear, :to_s, :to => :buffer

    def initialize
      @buffer_stack = []
      push
    end

    def buffer
      @buffer_stack.last
    end

    def push
      @buffer_stack.push ActiveSupport::SafeBuffer.new
    end

    def pop
      @buffer_stack.pop
    end
  end  
end