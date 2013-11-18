#encoding: utf-8
require 'openssl'
require 'yaml'
require 'cgi'
require "base64"

module KuaiQian
  module PayMent

    class << self

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
          attrs.inject({}){|o, k| o[_camelcase(k)] = get(k).to_s ; o }
        end

        def to_param
          attrs.map do |k|
            "#{_camelcase(k)}=#{CGI.escape(get(k).to_s.gsub(/\s/, ''))}"
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

        def sym_keys_slice!(opts, keys)
          value_hash(keys){|key| opts[key] }
        end

        def value_hash(values, &block)
          raise 'no block argument!' unless block_given?
          values.inject({}){|o, k| o[k.to_sym] = yield(k); o }
        end

        def sign_secret
          sign_type = get(:sign_type).to_s
          case sign_type
          when "4"
            openssl_sign
          when "1"
            md5_sign
          end
        end

        def sign_param
          data = params
          data.delete("signMsg")
          data.map do |k, v|
            v.nil? || v.empty? ? nil : "#{k}=#{v}"
          end.compact.join("&")
        end

        def md5_sign
          Digest::MD5.hexdigest(sign_param).upcase
        end

        def _underscore(value)
          value.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
        end

        def _camelcase(value, key = :lower)
          values = value.to_s.split(/[\W_]/).map{|c| c.capitalize }
          values[0] = values[0].downcase if key == :lower
          values.join
        end
      end

      class Request < Options

        def initialize(opts)
          super sym_keys_slice!(opts, attrs)
          set(:order_amount, 1) unless config[:environment] == "production"
          set(:sign_msg, sign_secret)
        end

        def attrs
          %w(
            inputCharset pageUrl bgUrl version language signType
            merchantAcctId payerName payerContactType payerContact
            orderId orderAmount orderTime productName productNum
            productId productDesc ext1 ext2 payType bankId redoFlag
            pid signMsg).map {|key| _underscore(key).to_sym  }
        end

        def openssl_sign
          pri = OpenSSL::PKey::RSA.new(File.read(config[:rsa]["pem_path"]), config[:rsa]["password"])
          sign = pri.sign(OpenSSL::Digest::SHA1.new, sign_param)
          Base64.encode64(sign).gsub(/\n/, '')
        end

        def sign_param
          super.gsub(/\s/, '')
        end

        def url
          "#{config[:remote]}?#{to_param}"
        end
      end

      class Response < Options

        def initialize(opts)
          super format_opts(opts)
        end

        def attrs
          %w(merchantAcctId version language signType
            payType bankId orderId orderTime orderAmount
            dealId bankDealId dealTime payAmount fee ext1
            ext2 payResult errCode signMsg).map {|key| _underscore(key).to_sym  }
        end

        def openssl_sign
          raw = File.read(config[:rsa]["cer_path"])
          sign_msg = Base64.decode64(attributes[:sign_msg])
          sign = OpenSSL::X509::Certificate.new(raw).public_key
          sign.verify(OpenSSL::Digest::SHA1.new, sign_msg, sign_param)
        end

        def md5_sign
          super == get(:sign_msg)
        end

        alias_method :sign_verify?, :sign_secret

        def successfully?
          puts sign_verify?
          get(:pay_result) == "10" && sign_verify?
        end

        private
        def format_opts(opts)
          opts.keys.inject({}) do |h, key|
            h[_underscore(key).to_sym] = opts[key]; h
          end
        end
      end

    end
  end
end
