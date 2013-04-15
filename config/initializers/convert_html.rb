#describe: 将string转换html
#author: huxinghai
require 'active_support/concern'

module Content
  module Html
    extend ActiveSupport::Concern
    include ActionView::Helpers::SanitizeHelper

    module InstanceMethods

      def format_html(content)
        text = HtmlTag.convert content
        LinkMatch.convert text
      end

    end

    class HtmlTag
      class << self
        def convert(text)
          br(space text)
        end

        private
        def space(text)
          text.gsub(/( |\t)/){ "&nbsp" * $1.size }
        end

        def br(text)
          text.gsub(/((?:\r\n|\r|\n))/){ "<br/>" }
        end
      end
    end

    class LinkMatch
      class << self

        def convert(text)
          _text = text.gsub(local_match){
            "<a href='#{$1}'>#{$1}</a>"
          }

          _text.gsub!(full_match){
            "<a href='#{$1}'>#{$1}</a>"
          }

          _text.gsub!(no_prefix_match){
            "<a href='http://#{$1}'>#{$1}</a>"
          }

          _text
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
          "(?:<br\/>|&nbsp|\s|^)"
        end

        def _end
          "(?:&nbsp|\s|$)"
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
  end
end