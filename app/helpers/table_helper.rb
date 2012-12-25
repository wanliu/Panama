require 'action_view/helpers/tag_helper'
require 'active_record'
require 'table_builder'

module TableHelper

  def table(records, options)
    adapter = options[:adapter] ||= :table
    build_klass = "table_builder/#{adapter}_builder".classify.constantize
    tb = build_klass.new(records, options)
    yield tb if block_given?
  end
end