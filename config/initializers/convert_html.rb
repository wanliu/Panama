#describe: 将string转换html
#author: huxinghai
require 'active_support/concern'

module Convert
  module Html
    extend ActiveSupport::Concern

    module ClassMethods
      def define_format_rule(reg, &block)
        @customer_match_rule ||= CustomerMatch.new
        @customer_match_rule.stores << [reg, block]
      end

      def customer_match_rule
        @customer_match_rule
      end
    end

    module InstanceMethods

      def format_html(content)
        text = HtmlTag.convert(LinkMatch.tag content)
        text = LinkMatch.convert_tag(text)
        text = _customer.convert(text) unless _customer.nil?
        text
      end

      private
      def _customer
        self.class.customer_match_rule
      end
    end

    class HtmlTag
      class << self
        def convert(text)
          br(space text)
        end

        private
        def space(text)
          text.gsub(/( |\t)/){ "&nbsp" }
        end

        def br(text)
          text.gsub(/((?:\r\n|\r|\n))/){ "<br/>" }
        end
      end
    end

    class LinkMatch
      class << self

        def tag(text)
          _text = text.gsub(local_match){
            "<a>#{$1}</a>"
          }

          _text.gsub!(full_match){
            "<a>#{$1}</a>"
          }

          _text.gsub!(no_prefix_match){
            "<a>#{$1}</a>"
          }
          _text
        end

        def convert_tag(text)
          content = tag text
          content.gsub(/<a>(.+)<\/a>/){
            "<a href='#{$1}'>#{$1}</a>"
          }
        end

        private
        #匹配本地url
        def local_match
          /#{_begin}(
            (?:http:\/\/|ftp:\/\/)(?:[a-zA-z_]+-?\.?[a-zA-z_]+|\d+\.\d+\.\d+\.\d+)
            (?::\d+)?(?:\/\w+-?\.?\w+)*
          )#{_end}/x
        end

        #匹配完整的url
        def full_match
          /#{_begin}(
            (?:http:\/\/|https:\/\/|ftp:\/\/)
            \w+-?\.?\w+\.(?:#{suffix})
            (?:\/\w+-?\.?\w+)*
          )#{_end}/x
        end

        def no_prefix_match
          /#{_begin}(
            (?:www.|\w+-?\.?\w+)
            \w+-?\.?\w+\.(?:#{suffix})
            (?:\/\w+-?\.?\w+)*
          )#{_end}/x
        end

        def _begin
          "(?:\s|^)"
        end

        def _end
          "(?:\s|$)"
        end

        def suffix
          %w(
            com org cn net pw la
            name cc me so co info
            biz hk tv tel asia travel
            gov.cn com.cn net.cn
            org.cn ac.cn mobi com.hk
          ).join("|")
        end
      end
    end

    class CustomerMatch
      attr_accessor :stores

      def initialize
        @stores = []
      end

      def convert(text)
        @stores.each_index do |i|
          text.gsub! @stores[i][0] do
            @stores[i][1].call($~)
          end
        end
        text
      end
    end
  end
end