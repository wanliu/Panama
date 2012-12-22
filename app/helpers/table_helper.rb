require 'action_view/helpers/tag_helper'
require 'active_record'

module TableHelper

  def table(records, options)
    tb = TableBuilder.new(records, options)
    yield tb if block_given?
  end

  class TableBuilder
    include ActionView::Helpers::TagHelper
    # include I18nHelper::Model::Helpers

    # model_klass :record, "record", Record
    attr_accessor :output_buffer
    attr_reader :ignore_names, :content

    def output_buffer 
      @output_buffer ||= ActiveSupport::SafeBuffer.new
    end

    def initialize(records = nil, options = {})
      @additional_heads = {}
      @hidden_heads = []
      @heads = options[:heads]
      add_columns = options[:add_column] || []
      add_columns.each do |col|
        name = col.keys[0]
        value = col.values[0]
        @additional_heads[name] = {:name => name , :proc => value } 
      end
      @hidden_heads = options[:hide_column] || []
    end

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
              output_buffer << content_to(col)
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
      output_buffer
    end

    def content_to(col)
      case col
      when DateTime, Time ,Date
        I18n.l col, :format => :short
      else
        col.to_s
      end
    end

    def table_footer(options = {})
      tag "/table", nil, true
    end

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
        [args[0] || {}, args[1] || {} , args[2] || {}]
      end

      def parse_row_args(args)
        [args[0] || {}, args[1] || {} ]
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
end