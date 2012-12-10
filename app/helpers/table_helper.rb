require 'action_view/helpers/tag_helper'

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

    def initialize(records = nil, options)
      # ignore_names.concat(options[:ignore_heads] || [])

      # case model_klass
      # when Symbol
      #   klass = model_klass.to_s.classify.constantize
      # when String
      #   klass = model_klass.classify.constantize
      # when Class
      #   klass = model_klass
      # else
      #   raise ArgumentError.new 'invalide type, must be Symbol, String, or Model Class'
      # end

      # @heads = klass.fields.keys - ignore_names
    end

    def table_head(heads, *args)
      @heads ||= heads
      table_options, tr_options, th_options = parse_head_args args
      cleanup!

      output_buffer << tag("table", table_options, true)
      output_buffer << (content_tag :thead do 
          content_tag :tr, tr_options do 
          @heads.each do |column|
            output_buffer << content_tag(:th, I18n.t("mongoid.attributes.content.#{column}"), th_options)
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
            col = row.read_attribute(column.to_sym)
            # todo: how to pass format options argument
            # todo: how to change time to user timezone
            output_buffer << (case col
                              when DateTime, Time ,Date
                                I18n.l col, :format => :short
                              else
                                col.to_s
                              end)
          end
        end
      end
      output_buffer
    end

    def table_footer(options)
      tag "/table", nil, true
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

end