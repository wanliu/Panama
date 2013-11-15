#encoding: utf-8
require 'openssl'
require 'yaml'
require 'cgi'

module KuaiQian
  module PayMent

    class << self

      REQUEST_PARAMS = %w(inputCharset pageUrl bgUrl
        payerName payerContactType payerContact
        productName productNum productId productDesc
        redoFlag pid)

      QUERY_PARAMS = %w(dealId bankDealId dealTime
        payResult errCode fee)

      def request(options)
        Request.new(options)
      end

      def response(options)
        Response.new(options)
      end

      def config
        @config ||= YAML::load_file("config/kuaiqian_payment.yml")
        @config
      end

      private

      class Options

        def initialize(opts = {})
          attrs.each{|name| set(name, opts[name]) }
          default
        end

        def set(name, value)
          instance_variable_set("@#{name}", value)
        end

        def get(name)
          instance_variable_get("@#{name}")
        end

        def attributes
          value_hash(attrs){|k| get(k) }
        end

        def params
          attrs.inject({}){|o, k| o[k.to_s.camelcase(:lower)] = get(k).to_s ; o }
        end

        def to_param
          attrs.map do |k|
            "#{k.to_s.camelcase(:lower)}=#{CGI.escape(get(k).to_s)}"
          end.join("&")
        end

        def default
          config[:params].each{|k, v| set(k, v) }

          @order_time ||= DateTime.now.strftime("%Y%m%d%H%M%S")
          @input_charset ||= "1"
          @language ||= "1"
          @pay_type ||= "00"
          @redo_flag ||= "0"
          @sign_type ||= "4"
        end

        def config
          sym_keys(KuaiQian::PayMent.config)
        end

        def sym_keys(opts)
          value_hash(opts.keys){|key| opts[key] }
        end

        def value_hash(values, &block)
          raise 'no block argument!' unless block_given?
          values.inject({}){|o, k| o[k.to_sym] = yield(k); o }
        end
      end

      class RequestOptions < Options

        def initialize(opts)
          set(:order_amount, 1) unless config[:environment] == "production"
          super sym_keys(opts).slice!(attrs)
        end

        def attrs
          %w(
            inputCharset pageUrl bgUrl version language signType
            merchantAcctId payerName payerContactType payerContact
            orderId orderAmount orderTime productName productNum
            productId productDesc ext1 ext2 payType bankId redoFlag
            pid sign_msg).map {|key| key.underscore.to_sym  }
        end
      end

      class Request

        def initialize(opts = {})
          @options = RequestOptions.new(opts)
          @options.set(:sign_msg, sign_msg)
        end

        def openssl_sign
          pri = OpenSSL::PKey::RSA.new(File.read(config[:rsa]["path"]), config[:rsa]["password"])
          sign = pri.sign(OpenSSL::Digest::SHA1.new, sign_param)
          Base64.encode64(sign).gsub(/\n/, '')
        end

        def to_param
          @options.to_param
        end

        def sign_param
          data = params
          data.delete("signMsg")
          data.map do |k, v|
            v.blank? ? nil : "#{k}=#{v}"
          end.compact.join("&").gsub(/\s/, '')
        end

        def config
          @options.config
        end

        def md5_sign
          Digest::MD5.hexdigest(sign_param)
        end

        def attributes
          @options.attributes
        end

        def params
          @options.params
        end

        def url
          "#{config[:remote]}?#{to_param}"
        end

        private
        def sign_msg
          sign_type = @options.get(:sign_type).to_s
          case sign_type
          when "4"
            openssl_sign
          when "1"
            md5_sign
          end
        end
      end

      class ResponseOptions < Options

        def initialize(opts)

          super opts
        end

        def attrs
          super + QUERY_PARAMS.map {|key| key.underscore.to_sym  }
        end
      end

      class Response

        def initialize(opts)
          @options = Options.new(opts)
        end

        def successful!

        end
      end

    end
  end
end
