module Custom
  module Validators
    class SuperiorValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        target = record.send(options[:target])
        att = options[:att] || attribute
        field = record.send(attribute)
        if field.blank? && target.respond_to?(:children) && target.children.size > 0
          record.errors.add att, "#{att}_message"
        end
      end
    end
  end
end