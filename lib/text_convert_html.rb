#describe: 将string转换html
#author: huxinghai
require 'active_support/concern'

module TextFormat
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

    def text_format_html(content)
      text = LinkMatch.convert(content)
      text = HtmlTag.convert(text)
      text = _customer.convert(text) unless _customer.nil?
      text
    end

    private
    def _customer
      self.class.customer_match_rule
    end

    class HtmlTag
      class << self
        def convert(text)
          celar_el_space(br(space text))
        end

        private
        def space(text)
          text.gsub(/( |\t)/, "&nbsp")
        end

        def br(text)
          text.gsub(/((?:\r\n|\r|\n))/, "<br/>")
        end

        def celar_el_space(text)
          text.gsub(/(?<=<[^>])&nbsp/, " ")
        end
      end
    end

    class LinkMatch
      class << self
        def convert(text)
          _text = text.gsub(local_match){
            "#{$1}<a href='#{$2}'>#{$2}</a>#{$3}"
          }

          _text.gsub!(full_match){
            "#{$1}<a href='#{$2}'>#{$2}</a>#{$3}"
          }

          _text.gsub!(no_prefix_match){
            "#{$1}<a href='http://#{$2}'>#{$2}</a>#{$3}"
          }
          _text
        end

        private
        #匹配本地url
        def local_match
          /((?:\s|^))(
            (?:http:\/\/|ftp:\/\/)
            (?:[a-zA-z_]+-?\.?[a-zA-z_]+|\d+\.\d+\.\d+\.\d+)
            (?::\d+)?(?:\/.+)*
          )((?:\s|$))/ix
        end

        #匹配完整的url
        def full_match
          /((?:\s|^))(
            (?:http:\/\/|https:\/\/|ftp:\/\/)
            \w+-?\.?\w+\.(?:#{suffix})
            (?:\/.+)*
          )((?:\s|$))/ix
        end

        def no_prefix_match
          /((?:\s|^))(
            (?:www.|\w+-?\.?\w+)
            \w+-?\.?\w+\.(?:#{suffix})
            (?:\/.+)*
          )((?:\s|$))/ix
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
          store = @stores[i]
          text.gsub! store[0] do
            store[1].call($~)
          end
        end
        text
      end
    end
  end
end