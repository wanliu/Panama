require "rails_autolink"

module TextFormat
  module Html
    extend ActiveSupport::Concern
    include ActionView::Helpers::TextHelper

    module ClassMethods
      def define_format_rule(reg, &block)
        @customer_match_rule ||= CustomerMatch.new
        @customer_match_rule.stores << [reg, block]
      end

      def customer_match_rule
        @customer_match_rule
      end
    end

    def text_format_html(content)
      text = simple_format auto_link(content)
      text = _customer.convert(text) unless _customer.nil?
      text
    end

    private
    def _customer
      self.class.customer_match_rule
    end

    class CustomerMatch
      attr_accessor :stores

      def initialize
        @stores = []
      end

      def convert(text)
        @stores.each_index do |i|
          store = @stores[i]
          text.gsub! store[0] do |match|
            store[1].call(match)
          end
        end
        text
      end
    end
  end
end